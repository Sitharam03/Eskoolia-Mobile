import 'package:get/get.dart';
import '../models/student_model.dart';
import '../repositories/students_repository.dart';

class StudentPromoteController extends GetxController {
  final _repo = StudentsRepository();

  final students = <StudentRow>[].obs;
  final academicYears = <Map<String, dynamic>>[].obs;
  final classes = <Map<String, dynamic>>[].obs;
  final sections = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final isPromoting = false.obs;

  // Source filters
  final sourceClassId = Rxn<int>();
  final sourceSectionId = Rxn<int>();

  // Target
  final targetAcademicYearId = Rxn<int>();
  final targetClassId = Rxn<int>();
  final targetSectionId = Rxn<int>();

  final selectedStudentIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      academicYears.value = results[0] as List<Map<String, dynamic>>;
      classes.value = results[1] as List<Map<String, dynamic>>;
      sections.value = results[2] as List<Map<String, dynamic>>;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load data',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchStudents() async {
    if (sourceClassId.value == null) {
      Get.snackbar('Filter', 'Please select a source class',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final params = <String, dynamic>{
        'is_active': 'true',
        'page_size': 500,
        'current_class': sourceClassId.value!,
      };
      if (sourceSectionId.value != null) {
        params['current_section'] = sourceSectionId.value!;
      }
      students.value = await _repo.getStudents(queryParams: params);
      selectedStudentIds.clear();
    } catch (_) {
      Get.snackbar('Error', 'Failed to load students',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStudentSelection(int id) {
    if (selectedStudentIds.contains(id)) {
      selectedStudentIds.remove(id);
    } else {
      selectedStudentIds.add(id);
    }
  }

  void selectAll() => selectedStudentIds.addAll(students.map((s) => s.id));
  void clearAll() => selectedStudentIds.clear();

  List<Map<String, dynamic>> get targetSections {
    if (targetClassId.value == null) return sections;
    return sections
        .where((s) => s['school_class'] == targetClassId.value)
        .toList();
  }

  List<Map<String, dynamic>> get sourceSections {
    if (sourceClassId.value == null) return sections;
    return sections
        .where((s) => s['school_class'] == sourceClassId.value)
        .toList();
  }

  String className(int? id) {
    if (id == null) return '—';
    return classes.firstWhereOrNull((c) => c['id'] == id)?['name']
            as String? ??
        '—';
  }

  String sectionName(int? id) {
    if (id == null) return '—';
    return sections.firstWhereOrNull((s) => s['id'] == id)?['name']
            as String? ??
        '—';
  }

  Future<void> promote() async {
    if (selectedStudentIds.isEmpty) {
      Get.snackbar('Validation', 'Please select at least one student',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (targetClassId.value == null || targetAcademicYearId.value == null) {
      Get.snackbar('Validation',
          'Please select target academic year and class',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isPromoting.value = true;
    try {
      await _repo.promoteStudents({
        'student_ids': selectedStudentIds.toList(),
        'target_academic_year': targetAcademicYearId.value,
        'target_class': targetClassId.value,
        if (targetSectionId.value != null)
          'target_section': targetSectionId.value,
      });
      Get.snackbar('Success',
          '${selectedStudentIds.length} student(s) promoted successfully',
          snackPosition: SnackPosition.BOTTOM);
      selectedStudentIds.clear();
      students.clear();
      sourceClassId.value = null;
      sourceSectionId.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to promote students: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isPromoting.value = false;
    }
  }
}
