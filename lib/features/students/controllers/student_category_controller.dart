import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_category_model.dart';
import '../repositories/students_repository.dart';

class StudentCategoryController extends GetxController {
  final _repo = StudentsRepository();

  final categories = <StudentCategory>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final editingId = Rxn<int>();
  final searchQuery = ''.obs;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.value = await _repo.getCategories();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load categories'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentCategory> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return categories;
    return categories
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }

  void startEdit(StudentCategory cat) {
    editingId.value = cat.id;
    nameCtrl.text = cat.name;
    descriptionCtrl.text = cat.description;
  }

  void resetForm() {
    editingId.value = null;
    nameCtrl.clear();
    descriptionCtrl.clear();
  }

  Future<bool> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Category name is required',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isSaving.value = true;
    try {
      final data = {
        'name': nameCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await _repo.updateCategory(editingId.value!, data);
        Get.snackbar('Success', 'Category updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await _repo.createCategory(data);
        Get.snackbar('Success', 'Category created',
            snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
      await loadCategories();
      return true;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to save category'),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      Get.snackbar('Deleted', 'Category removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to delete category'),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
