import 'package:get/get.dart';
import '../models/student_model.dart';
import '../models/student_category_model.dart';
import '../models/guardian_model.dart';
import '../repositories/students_repository.dart';

class StudentDisabledController extends GetxController {
  final _repo = StudentsRepository();

  final students = <StudentRow>[].obs;
  final categories = <StudentCategory>[].obs;
  final guardians = <Guardian>[].obs;
  final classes = <Map<String, dynamic>>[].obs;
  final sections = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;
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
        _repo.getStudents(
            queryParams: {'page_size': 1000, 'is_disabled': 'true'}),
        _repo.getCategories(),
        _repo.getGuardians(),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      students.value = (results[0] as List<StudentRow>)
          .where((s) => s.isDisabled)
          .toList();
      categories.value = results[1] as List<StudentCategory>;
      guardians.value = results[2] as List<Guardian>;
      classes.value = results[3] as List<Map<String, dynamic>>;
      sections.value = results[4] as List<Map<String, dynamic>>;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load disabled students',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentRow> get filtered {
    var list = students.toList();

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

  Future<void> enableStudent(int id) async {
    try {
      await _repo.updateStudent(id, {'is_disabled': false});
      students.removeWhere((s) => s.id == id);
      Get.snackbar('Success', 'Student enabled',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _repo.deleteStudent(id);
      students.removeWhere((s) => s.id == id);
      Get.snackbar('Deleted', 'Student permanently deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e', snackPosition: SnackPosition.BOTTOM);
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

  String guardianPhone(int? id) {
    if (id == null) return '';
    return guardians.firstWhereOrNull((g) => g.id == id)?.phone ?? '';
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
