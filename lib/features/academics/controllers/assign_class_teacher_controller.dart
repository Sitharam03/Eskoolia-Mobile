import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class AssignClassTeacherController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final teachers = <Teacher>[].obs;

  // List
  final items = <ClassTeacherAssignment>[].obs;
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
  final teacherId = ''.obs;
  final isSaving = false.obs;

  List<Section> get availableSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  List<Section> get filterSections =>
      sections.where((s) => s.schoolClass == int.tryParse(filterClassId.value)).toList();

  String className(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');

  String sectionName(int? id) =>
      id == null ? '-' : (sections.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String teacherName(int? id) =>
      id == null ? '-' : (teachers.firstWhereOrNull((t) => t.id == id)?.displayName ?? '#$id');

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
      _repo.getTeachers(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    teachers.value = results[3] as List<Teacher>;
    if (yearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      yearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      error.value = '';
      items.value = await _repo.getClassTeachers(
        classId: filterClassId.value.isEmpty ? null : filterClassId.value,
        sectionId: filterSectionId.value.isEmpty ? null : filterSectionId.value,
      );
    } catch (e) {
      error.value = ApiError.extract(e, 'Unable to load class teacher assignments.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (classId.isEmpty || teacherId.isEmpty) {
      error.value = 'Class and teacher are required.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      await _repo.saveClassTeacher(
        {
          'academic_year_id': yearId.isNotEmpty ? int.parse(yearId.value) : null,
          'class_id': int.parse(classId.value),
          'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
          'teacher_id': int.parse(teacherId.value),
          'active_status': true,
        },
        id: editingId.value,
      );
      message.value =
          editingId.value != null ? 'Assignment updated.' : 'Class teacher assigned.';
      resetForm();
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to save class teacher assignment.');
    } finally {
      isSaving.value = false;
    }
  }

  void startEdit(ClassTeacherAssignment row) {
    editingId.value = row.id;
    yearId.value = row.academicYearId?.toString() ?? '';
    classId.value = row.classId.toString();
    sectionId.value = row.sectionId?.toString() ?? '';
    teacherId.value = row.teacherId.toString();
    error.value = '';
    message.value = '';
  }

  Future<void> delete(int id) async {
    try {
      error.value = '';
      await _repo.deleteClassTeacher(id);
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to delete.');
    }
  }

  void resetForm() {
    editingId.value = null;
    classId.value = '';
    sectionId.value = '';
    teacherId.value = '';
    error.value = '';
    message.value = '';
  }
}
