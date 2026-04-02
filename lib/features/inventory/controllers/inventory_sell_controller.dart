import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventorySellController extends GetxController {
  final _repo = InventoryRepository();

  final sells = <ItemSell>[].obs;
  final items = <InventoryItem>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  final sellDateCtrl = TextEditingController();
  final soldToCtrl = TextEditingController();
  final discountCtrl = TextEditingController(text: '0.00');
  final taxCtrl = TextEditingController(text: '0.00');
  final paidAmountCtrl = TextEditingController(text: '0.00');
  final selectedPaymentStatus = 'U'.obs;
  final notesCtrl = TextEditingController();
  final lineItems = <SellLineItemForm>[].obs;

  static const paymentStatusOptions = [
    _SellStatusOption('U', 'Unpaid'),
    _SellStatusOption('PP', 'Partial'),
    _SellStatusOption('P', 'Paid'),
  ];

  @override
  void onInit() {
    super.onInit();
    _addLineItem();
    load();
  }

  @override
  void onClose() {
    sellDateCtrl.dispose();
    soldToCtrl.dispose();
    discountCtrl.dispose();
    taxCtrl.dispose();
    paidAmountCtrl.dispose();
    notesCtrl.dispose();
    _disposeLineItems();
    super.onClose();
  }

  void _disposeLineItems() {
    for (final li in lineItems) {
      li.dispose();
    }
  }

  void _addLineItem() => lineItems.add(SellLineItemForm());

  void addLineItem() => _addLineItem();

  void removeLineItem(int index) {
    if (lineItems.length <= 1) return;
    lineItems[index].dispose();
    lineItems.removeAt(index);
  }

  double get computedTotal {
    final subtotal = lineItems.fold<double>(
        0, (sum, li) => sum + ((double.tryParse(li.qtyCtrl.text) ?? 0) * (double.tryParse(li.priceCtrl.text) ?? 0)));
    final discount = double.tryParse(discountCtrl.text) ?? 0;
    final tax = double.tryParse(taxCtrl.text) ?? 0;
    return subtotal - discount + tax;
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getSells(),
        _repo.getItems(),
      ]);
      sells.value = results[0] as List<ItemSell>;
      items.value = results[1] as List<InventoryItem>;
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    sellDateCtrl.clear();
    soldToCtrl.clear();
    discountCtrl.text = '0.00';
    taxCtrl.text = '0.00';
    paidAmountCtrl.text = '0.00';
    selectedPaymentStatus.value = 'U';
    notesCtrl.clear();
    _disposeLineItems();
    lineItems.clear();
    _addLineItem();
    errorMsg.value = '';
  }

  Future<void> save() async {
    final validLines = lineItems.where((li) => li.selectedItemId.value != null).toList();
    if (sellDateCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Sell date is required.';
      return;
    }
    if (validLines.isEmpty) {
      errorMsg.value = 'Add at least one line item with an item selected.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = {
        'sell_date': sellDateCtrl.text.trim(),
        'sold_to': soldToCtrl.text.trim(),
        'discount': double.tryParse(discountCtrl.text) ?? 0,
        'tax': double.tryParse(taxCtrl.text) ?? 0,
        'paid_amount': double.tryParse(paidAmountCtrl.text) ?? 0,
        'payment_status': selectedPaymentStatus.value,
        'notes': notesCtrl.text.trim(),
        'line_items': validLines.map((li) => li.toJson()).toList(),
      };
      await _repo.createSell(data);
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
      await _repo.deleteSell(id);
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e);
    }
  }
}

class _SellStatusOption {
  final String value;
  final String label;
  const _SellStatusOption(this.value, this.label);
}
