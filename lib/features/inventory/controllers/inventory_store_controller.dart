import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventoryStoreController extends GetxController {
  final _repo = InventoryRepository();

  final stores = <ItemStore>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);

  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  List<ItemStore> get filteredStores {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return stores.toList();
    return stores
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.location.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      stores.value = await _repo.getStores();
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(ItemStore store) {
    editingId.value = store.id;
    titleCtrl.text = store.title;
    locationCtrl.text = store.location;
    descCtrl.text = store.description;
  }

  void cancelEdit() {
    editingId.value = null;
    titleCtrl.clear();
    locationCtrl.clear();
    descCtrl.clear();
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Store title is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = {
        'title': titleCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'description': descCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await _repo.updateStore(editingId.value!, data);
      } else {
        await _repo.createStore(data);
      }
      cancelEdit();
      await load();
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteStore(id);
      await load();
    } catch (e) {
      errorMsg.value = e.toString();
    }
  }
}
