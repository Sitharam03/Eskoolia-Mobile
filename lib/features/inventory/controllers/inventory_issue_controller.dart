import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventoryIssueController extends GetxController {
  final _repo = InventoryRepository();

  final issues = <ItemIssue>[].obs;
  final stores = <ItemStore>[].obs;
  final items = <InventoryItem>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  final selectedStoreId = Rx<int?>(null);
  final selectedItemId = Rx<int?>(null);
  final quantityCtrl = TextEditingController(text: '1');
  final subjectCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    quantityCtrl.dispose();
    subjectCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getIssues(),
        _repo.getStores(),
        _repo.getItems(),
      ]);
      issues.value = results[0] as List<ItemIssue>;
      stores.value = results[1] as List<ItemStore>;
      items.value = results[2] as List<InventoryItem>;
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    selectedStoreId.value = null;
    selectedItemId.value = null;
    quantityCtrl.text = '1';
    subjectCtrl.clear();
    notesCtrl.clear();
    errorMsg.value = '';
  }

  Future<void> save() async {
    if (selectedItemId.value == null) {
      errorMsg.value = 'Please select an item.';
      return;
    }
    if (subjectCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Subject is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = <String, dynamic>{
        'item': selectedItemId.value,
        'quantity': double.tryParse(quantityCtrl.text) ?? 1,
        'subject': subjectCtrl.text.trim(),
        'notes': notesCtrl.text.trim(),
        if (selectedStoreId.value != null) 'store': selectedStoreId.value,
      };
      await _repo.createIssue(data);
      resetForm();
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteIssue(id);
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    }
  }
}
