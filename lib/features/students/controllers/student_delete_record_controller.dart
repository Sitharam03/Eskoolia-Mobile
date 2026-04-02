import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_model.dart';
import '../models/guardian_model.dart';
import '../repositories/students_repository.dart';

class StudentDeleteRecordController extends GetxController {
  final _repo = StudentsRepository();

  final allStudents = <StudentRow>[].obs;
  final guardians = <Guardian>[].obs;
  final classes = <Map<String, dynamic>>[].obs;
  final sections = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // 0 = Active tab (can soft-delete), 1 = Deleted tab (can restore / hard-delete)
  final activeTab = 0.obs;

  final filterClassId = Rxn<int>();
  final filterSectionId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getStudents(queryParams: {'page_size': 1000}),
        _repo.getGuardians(),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      allStudents.value = results[0] as List<StudentRow>;
      guardians.value = results[1] as List<Guardian>;
      classes.value = results[2] as List<Map<String, dynamic>>;
      sections.value = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load records'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentRow> get _activeStudents =>
      allStudents.where((s) => s.isActive && !s.isDisabled).toList();

  List<StudentRow> get _deletedStudents =>
      allStudents.where((s) => !s.isActive).toList();

  List<StudentRow> get filtered {
    final base =
        activeTab.value == 0 ? _activeStudents : _deletedStudents;

    var list = base;
    if (filterClassId.value != null) {
      list = list.where((s) => s.currentClass == filterClassId.value).toList();
    }
    if (filterSectionId.value != null) {
      list =
          list.where((s) => s.currentSection == filterSectionId.value).toList();
    }

    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((s) =>
              s.fullName.toLowerCase().contains(q) ||
              s.admissionNo.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  // Soft delete (active → deleted)
  Future<void> softDelete(int id) async {
    try {
      await _repo.updateStudent(id, {'is_active': false});
      final idx = allStudents.indexWhere((s) => s.id == id);
      if (idx >= 0) {
        allStudents[idx] = allStudents[idx].copyWith(isActive: false);
      }
      Get.snackbar('Deleted', 'Student moved to deleted records',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to delete student'), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Restore (deleted → active)
  Future<void> restore(int id) async {
    try {
      await _repo.updateStudent(id, {'is_active': true});
      final idx = allStudents.indexWhere((s) => s.id == id);
      if (idx >= 0) {
        allStudents[idx] = allStudents[idx].copyWith(isActive: true);
      }
      Get.snackbar('Restored', 'Student restored',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to restore student'), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Permanent delete
  Future<void> permanentDelete(int id) async {
    try {
      await _repo.deleteStudent(id);
      allStudents.removeWhere((s) => s.id == id);
      Get.snackbar('Deleted', 'Student permanently deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to permanently delete student'), snackPosition: SnackPosition.BOTTOM);
    }
  }

  String guardianName(int? id) {
    if (id == null) return '—';
    return guardians.firstWhereOrNull((g) => g.id == id)?.fullName ?? '—';
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

  List<Map<String, dynamic>> get sectionsForClass {
    if (filterClassId.value == null) return sections;
    return sections
        .where((s) => s['school_class'] == filterClassId.value)
        .toList();
  }
}
