import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventoryItemController extends GetxController {
  final _repo = InventoryRepository();

  static const unitOptions = ['piece', 'box', 'dozen', 'meter', 'kg', 'liter'];

  final items = <InventoryItem>[].obs;
  final categories = <ItemCategory>[].obs;
  final suppliers = <Supplier>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);
  final showLowStockOnly = false.obs;

  final itemCodeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '0');
  final selectedUnit = 'piece'.obs;
  final reorderLevelCtrl = TextEditingController(text: '0');
  final unitCostCtrl = TextEditingController(text: '0.00');
  final unitPriceCtrl = TextEditingController(text: '0.00');
  final selectedCategoryId = Rx<int?>(null);
  final selectedSupplierId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    itemCodeCtrl.dispose();
    nameCtrl.dispose();
    quantityCtrl.dispose();
    reorderLevelCtrl.dispose();
    unitCostCtrl.dispose();
    unitPriceCtrl.dispose();
    super.onClose();
  }

  int get lowStockCount => items.where((i) => i.isLowStock).length;

  List<InventoryItem> get filteredItems {
    var list = items.toList();
    if (showLowStockOnly.value) list = list.where((i) => i.isLowStock).toList();
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.itemCode.toLowerCase().contains(q) ||
            i.categoryTitle.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getItems(),
        _repo.getCategories(),
        _repo.getSuppliers(),
      ]);
      items.value = results[0] as List<InventoryItem>;
      categories.value = results[1] as List<ItemCategory>;
      suppliers.value = results[2] as List<Supplier>;
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(InventoryItem item) {
    editingId.value = item.id;
    itemCodeCtrl.text = item.itemCode;
    nameCtrl.text = item.name;
    quantityCtrl.text = item.quantity.toString();
    selectedUnit.value =
        unitOptions.contains(item.unit) ? item.unit : 'piece';
    reorderLevelCtrl.text = item.reorderLevel.toString();
    unitCostCtrl.text = item.unitCost.toStringAsFixed(2);
    unitPriceCtrl.text = item.unitPrice.toStringAsFixed(2);
    selectedCategoryId.value = item.categoryId;
    selectedSupplierId.value = item.supplierId;
  }

  void cancelEdit() {
    editingId.value = null;
    itemCodeCtrl.clear();
    nameCtrl.clear();
    quantityCtrl.text = '0';
    selectedUnit.value = 'piece';
    reorderLevelCtrl.text = '0';
    unitCostCtrl.text = '0.00';
    unitPriceCtrl.text = '0.00';
    selectedCategoryId.value = null;
    selectedSupplierId.value = null;
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Item name is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = <String, dynamic>{
        'item_code': itemCodeCtrl.text.trim(),
        'name': nameCtrl.text.trim(),
        'quantity': double.tryParse(quantityCtrl.text) ?? 0,
        'unit': selectedUnit.value,
        'reorder_level': double.tryParse(reorderLevelCtrl.text) ?? 0,
        'unit_cost': double.tryParse(unitCostCtrl.text) ?? 0,
        'unit_price': double.tryParse(unitPriceCtrl.text) ?? 0,
        if (selectedCategoryId.value != null)
          'category': selectedCategoryId.value,
        if (selectedSupplierId.value != null)
          'supplier': selectedSupplierId.value,
      };
      if (editingId.value != null) {
        await _repo.updateItem(editingId.value!, data);
      } else {
        await _repo.createItem(data);
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
      await _repo.deleteItem(id);
      await load();
    } catch (e) {
      errorMsg.value = e.toString();
    }
  }
}
