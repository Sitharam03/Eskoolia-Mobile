import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class ClassRoutineController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  static const List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;
  final teachers = <Teacher>[].obs;
  final periods = <ClassPeriod>[].obs;
  final rooms = <ClassRoom>[].obs;

  // List
  final items = <ClassRoutineSlot>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // Filter / tab
  final filterClassId = ''.obs;
  final filterSectionId = ''.obs;
  final activeDayTab = 'monday'.obs;

  // Form
  final editingId = RxnInt();
  final yearId = ''.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final subjectId = ''.obs;
  final teacherId = ''.obs;
  final day = 'monday'.obs;
  final periodId = ''.obs;
  final startTime = ''.obs;
  final endTime = ''.obs;
  final roomId = ''.obs;
  final roomText = ''.obs;
  final isBreak = false.obs;
  final isSaving = false.obs;

  List<Section> get availableSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  List<Section> get filterSections =>
      sections.where((s) => s.schoolClass == int.tryParse(filterClassId.value)).toList();

  List<ClassRoutineSlot> get itemsForActiveDay =>
      items.where((s) => s.day.toLowerCase() == activeDayTab.value).toList();

  String className(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');

  String sectionName(int? id) =>
      id == null ? '-' : (sections.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String subjectName(int? id) =>
      id == null ? '-' : (subjects.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String teacherName(int? id) =>
      id == null ? '-' : (teachers.firstWhereOrNull((t) => t.id == id)?.displayName ?? '#$id');

  String periodName(int? id) =>
      id == null ? '-' : (periods.firstWhereOrNull((p) => p.id == id)?.label ?? '#$id');

  String roomName(int? id) =>
      id == null ? '-' : (rooms.firstWhereOrNull((r) => r.id == id)?.roomNo ?? '#$id');

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
    loadItems();
    // Auto-fill times when periodId changes
    ever(periodId, (_) => _autofillPeriodTimes());
  }

  void _autofillPeriodTimes() {
    final pid = int.tryParse(periodId.value);
    if (pid == null) return;
    final period = periods.firstWhereOrNull((p) => p.id == pid);
    if (period != null) {
      startTime.value = period.startTime ?? '';
      endTime.value = period.endTime ?? '';
    }
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _repo.getAcademicYears(),
      _repo.getClasses(),
      _repo.getSections(),
      _repo.getSubjects(),
      _repo.getTeachers(),
      _repo.getClassPeriods(),
      _repo.getClassRooms(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    subjects.value = results[3] as List<Subject>;
    teachers.value = results[4] as List<Teacher>;
    periods.value = results[5] as List<ClassPeriod>;
    rooms.value = results[6] as List<ClassRoom>;
    if (yearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      yearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  Future<void> loadItems({String? classIdOverride, String? sectionIdOverride, String? dayOverride}) async {
    try {
      isLoading.value = true;
      error.value = '';
      items.value = await _repo.getClassRoutines(
        classId: (classIdOverride ?? filterClassId.value).isEmpty
            ? null
            : (classIdOverride ?? filterClassId.value),
        sectionId: (sectionIdOverride ?? filterSectionId.value).isEmpty
            ? null
            : (sectionIdOverride ?? filterSectionId.value),
        day: dayOverride,
      );
    } catch (e) {
      error.value = ApiError.extract(e, 'Unable to load class routine.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (classId.isEmpty || subjectId.isEmpty || periodId.isEmpty) {
      error.value = 'Class, subject, and period are required.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      await _repo.saveClassRoutine(
        {
          'academic_year_id': yearId.isNotEmpty ? int.parse(yearId.value) : null,
          'class_id': int.parse(classId.value),
          'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
          'subject_id': isBreak.value ? null : int.tryParse(subjectId.value),
          'teacher_id': teacherId.isNotEmpty ? int.parse(teacherId.value) : null,
          'day': day.value,
          'period_id': int.parse(periodId.value),
          'start_time': startTime.value.isNotEmpty ? startTime.value : null,
          'end_time': endTime.value.isNotEmpty ? endTime.value : null,
          'room_id': roomId.isNotEmpty ? int.tryParse(roomId.value) : null,
          'room_text': roomText.value.isNotEmpty ? roomText.value : null,
          'is_break': isBreak.value,
          'active_status': true,
        },
        id: editingId.value,
      );
      message.value = editingId.value != null ? 'Routine slot updated.' : 'Routine slot added.';
      resetForm();
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to save class routine.');
    } finally {
      isSaving.value = false;
    }
  }

  void startEdit(ClassRoutineSlot slot) {
    editingId.value = slot.id;
    yearId.value = slot.academicYearId?.toString() ?? '';
    classId.value = slot.classId.toString();
    sectionId.value = slot.sectionId?.toString() ?? '';
    subjectId.value = slot.subjectId?.toString() ?? '';
    teacherId.value = slot.teacherId?.toString() ?? '';
    day.value = slot.day;
    periodId.value = slot.classPeriodId?.toString() ?? '';
    startTime.value = slot.startTime ?? '';
    endTime.value = slot.endTime ?? '';
    roomId.value = slot.roomId?.toString() ?? '';
    roomText.value = slot.room;
    isBreak.value = slot.isBreak;
    error.value = '';
    message.value = '';
  }

  Future<void> delete(int id) async {
    try {
      error.value = '';
      await _repo.deleteClassRoutine(id);
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to delete routine slot.');
    }
  }

  void resetForm() {
    editingId.value = null;
    classId.value = '';
    sectionId.value = '';
    subjectId.value = '';
    teacherId.value = '';
    day.value = 'monday';
    periodId.value = '';
    startTime.value = '';
    endTime.value = '';
    roomId.value = '';
    roomText.value = '';
    isBreak.value = false;
    error.value = '';
    message.value = '';
  }
}
