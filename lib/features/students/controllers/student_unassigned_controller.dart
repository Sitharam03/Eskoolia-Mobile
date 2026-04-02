import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_model.dart';
import '../models/student_category_model.dart';
import '../models/guardian_model.dart';
import '../repositories/students_repository.dart';

class StudentUnassignedController extends GetxController {
  final _repo = StudentsRepository();

  final students = <StudentRow>[].obs;
  final categories = <StudentCategory>[].obs;
  final guardians = <Guardian>[].obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getStudents(queryParams: {'page_size': 1000, 'is_active': 'true'}),
        _repo.getCategories(),
        _repo.getGuardians(),
      ]);
      final allStudents = results[0] as List<StudentRow>;
      // Unassigned = no current_class OR no current_section
      students.value = allStudents
          .where((s) =>
              !s.isDisabled &&
              s.isActive &&
              (s.currentClass == null || s.currentSection == null))
          .toList();
      categories.value = results[1] as List<StudentCategory>;
      guardians.value = results[2] as List<Guardian>;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load unassigned students'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentRow> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return students;
    return students
        .where((s) =>
            s.fullName.toLowerCase().contains(q) ||
            s.admissionNo.toLowerCase().contains(q))
        .toList();
  }

  Future<void> softDeleteStudent(int id) async {
    try {
      await _repo.updateStudent(id, {'is_active': false});
      students.removeWhere((s) => s.id == id);
      Get.snackbar('Done', 'Student moved to deleted records',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to delete student'), snackPosition: SnackPosition.BOTTOM);
    }
  }

  String categoryName(int? id) {
    if (id == null) return '—';
    return categories.firstWhereOrNull((c) => c.id == id)?.name ?? '—';
  }

  String guardianName(int? id) {
    if (id == null) return '—';
    return guardians.firstWhereOrNull((g) => g.id == id)?.fullName ?? '—';
  }
}
