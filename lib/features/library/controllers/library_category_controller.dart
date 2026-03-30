import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/library_models.dart';
import '../repositories/library_repository.dart';

class LibraryCategoryController extends GetxController {
  final _repo = LibraryRepository();

  final categories = <BookCategory>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  // Form
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final isActive = true.obs;
  final editingId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      categories.value = await _repo.getCategories();
    } catch (_) {
      errorMsg.value = 'Unable to load categories.';
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(BookCategory cat) {
    editingId.value = cat.id;
    nameCtrl.text = cat.name;
    descCtrl.text = cat.description;
    isActive.value = cat.isActive;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    nameCtrl.clear();
    descCtrl.clear();
    isActive.value = true;
    errorMsg.value = '';
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      errorMsg.value = 'Category name is required.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'name': name,
        'description': descCtrl.text.trim(),
        'is_active': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateCategory(editingId.value!, payload);
      } else {
        await _repo.createCategory(payload);
      }
      cancelEdit();
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to save category.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteCategory(id);
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to delete category.';
    }
  }
}
