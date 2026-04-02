import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

class ExamTypeController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Form fields
  final editingId = Rx<int?>(null);
  final titleCtrl = ''.obs;
  final isAverage = false.obs;
  final averageMark = '0.00'.obs;

  bool get isEditing => editingId.value != null;

  @override
  void onInit() {
    super.onInit();
    loadExamTypes();
  }

  Future<void> loadExamTypes() async {
    try {
      isLoading.value = true;
      examTypes.value = await _repo.getExamTypes();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load exam types'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startEdit(int id) async {
    try {
      final type = await _repo.getExamTypeById(id);
      editingId.value = type.id;
      titleCtrl.value = type.title;
      isAverage.value = type.isAverage;
      averageMark.value = type.averageMark;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load exam type for editing'),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void cancelEdit() {
    editingId.value = null;
    titleCtrl.value = '';
    isAverage.value = false;
    averageMark.value = '0.00';
  }

  Future<void> save() async {
    if (titleCtrl.value.trim().isEmpty) {
      Get.snackbar('Validation', 'Exam name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (isAverage.value && averageMark.value.trim().isEmpty) {
      Get.snackbar('Validation',
          'Average mark is required when average passing is enabled',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;
      final payload = {
        'id': editingId.value,
        'exam_type_title': titleCtrl.value.trim(),
        'is_average': isAverage.value ? 'yes' : '',
        'average_mark': double.tryParse(averageMark.value) ?? 0,
      };

      if (isEditing) {
        await _repo.updateExamType(payload);
      } else {
        await _repo.createExamType(payload);
      }

      cancelEdit();
      await loadExamTypes();
      Get.snackbar('Success', isEditing ? 'Exam type updated' : 'Exam type created',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteExamType(id);
      if (editingId.value == id) cancelEdit();
      await loadExamTypes();
      Get.snackbar('Deleted', 'Exam type deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to delete exam type'),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
