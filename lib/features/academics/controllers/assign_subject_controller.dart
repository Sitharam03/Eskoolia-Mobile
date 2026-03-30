import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class AssignSubjectController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;
  final teachers = <Teacher>[].obs;

  // List
  final items = <ClassSubjectAssignment>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // Filter
  final filterClassId = ''.obs;
  final filterSectionId = ''.obs;

  // Form
  final editingId = RxnInt();
  final yearId = ''.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final subjectId = ''.obs;
  final teacherId = ''.obs;
  final isOptional = false.obs;
  final isSaving = false.obs;

  List<Section> get availableSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  List<Section> get filterSections =>
      sections.where((s) => s.schoolClass == int.tryParse(filterClassId.value)).toList();

  String subjectName(int? id) =>
      id == null ? '-' : (subjects.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String teacherName(int? id) =>
      id == null ? '-' : (teachers.firstWhereOrNull((t) => t.id == id)?.displayName ?? '#$id');

  String className(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');

  String sectionName(int? id) =>
      id == null ? '-' : (sections.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
    loadItems();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _repo.getAcademicYears(),
      _repo.getClasses(),
      _repo.getSections(),
      _repo.getSubjects(),
      _repo.getTeachers(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    subjects.value = results[3] as List<Subject>;
    teachers.value = results[4] as List<Teacher>;
    if (yearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      yearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  Future<void> loadItems({String? classIdOverride, String? sectionIdOverride}) async {
    try {
      isLoading.value = true;
      error.value = '';
      items.value = await _repo.getClassSubjects(
        classId: (classIdOverride ?? filterClassId.value).isEmpty
            ? null
            : (classIdOverride ?? filterClassId.value),
        sectionId: (sectionIdOverride ?? filterSectionId.value).isEmpty
            ? null
            : (sectionIdOverride ?? filterSectionId.value),
      );
    } catch (_) {
      error.value = 'Unable to load subject assignments.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (classId.isEmpty || subjectId.isEmpty) {
      error.value = 'Class and subject are required.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      await _repo.saveClassSubject(
        {
          'academic_year_id': yearId.isNotEmpty ? int.parse(yearId.value) : null,
          'class_id': int.parse(classId.value),
          'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
          'subject_id': int.parse(subjectId.value),
          'teacher_id': teacherId.isNotEmpty ? int.parse(teacherId.value) : null,
          'is_optional': isOptional.value,
          'active_status': true,
        },
        id: editingId.value,
      );
      message.value =
          editingId.value != null ? 'Subject assignment updated.' : 'Subject assigned.';
      resetForm();
      await loadItems();
    } catch (_) {
      error.value = 'Failed to save subject assignment.';
    } finally {
      isSaving.value = false;
    }
  }

  void startEdit(ClassSubjectAssignment row) {
    editingId.value = row.id;
    yearId.value = row.academicYearId?.toString() ?? '';
    classId.value = row.classId.toString();
    sectionId.value = row.sectionId?.toString() ?? '';
    subjectId.value = row.subjectId.toString();
    teacherId.value = row.teacherId?.toString() ?? '';
    isOptional.value = row.isOptional;
    error.value = '';
    message.value = '';
  }

  Future<void> delete(int id) async {
    try {
      error.value = '';
      await _repo.deleteClassSubject(id);
      await loadItems();
    } catch (_) {
      error.value = 'Failed to delete.';
    }
  }

  void resetForm() {
    editingId.value = null;
    classId.value = '';
    sectionId.value = '';
    subjectId.value = '';
    teacherId.value = '';
    isOptional.value = false;
    error.value = '';
    message.value = '';
  }
}
