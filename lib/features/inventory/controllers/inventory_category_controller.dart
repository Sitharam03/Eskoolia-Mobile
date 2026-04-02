import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventoryCategoryController extends GetxController {
  final _repo = InventoryRepository();

  final categories = <ItemCategory>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  List<ItemCategory> get filteredCategories {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return categories.toList();
    return categories.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      categories.value = await _repo.getCategories();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(ItemCategory cat) {
    editingId.value = cat.id;
    titleCtrl.text = cat.title;
    descCtrl.text = cat.description;
    isActive.value = cat.isActive;
  }

  void cancelEdit() {
    editingId.value = null;
    titleCtrl.clear();
    descCtrl.clear();
    isActive.value = true;
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Category title is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = {
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'is_active': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateCategory(editingId.value!, data);
      } else {
        await _repo.createCategory(data);
      }
      cancelEdit();
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteCategory(id);
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    }
  }
}
