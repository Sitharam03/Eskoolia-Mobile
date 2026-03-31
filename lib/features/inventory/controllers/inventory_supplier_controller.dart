import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/inventory_models.dart';
import '../repositories/inventory_repository.dart';

class InventorySupplierController extends GetxController {
  final _repo = InventoryRepository();

  static const paymentTermsOptions = [
    'NET15', 'NET30', 'NET45', 'NET60', 'COD', 'PREPAID',
  ];

  final suppliers = <Supplier>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);

  final nameCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final taxIdCtrl = TextEditingController();
  final selectedPaymentTerms = 'NET30'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    contactCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    taxIdCtrl.dispose();
    super.onClose();
  }

  List<Supplier> get filteredSuppliers {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return suppliers.toList();
    return suppliers
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.phone.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      suppliers.value = await _repo.getSuppliers();
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(Supplier supplier) {
    editingId.value = supplier.id;
    nameCtrl.text = supplier.name;
    contactCtrl.text = supplier.contact;
    emailCtrl.text = supplier.email;
    phoneCtrl.text = supplier.phone;
    addressCtrl.text = supplier.address;
    taxIdCtrl.text = supplier.taxId;
    selectedPaymentTerms.value =
        paymentTermsOptions.contains(supplier.paymentTerms)
            ? supplier.paymentTerms
            : 'NET30';
  }

  void cancelEdit() {
    editingId.value = null;
    nameCtrl.clear();
    contactCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    taxIdCtrl.clear();
    selectedPaymentTerms.value = 'NET30';
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Supplier name is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final data = {
        'name': nameCtrl.text.trim(),
        'contact': contactCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'tax_id': taxIdCtrl.text.trim(),
        'payment_terms': selectedPaymentTerms.value,
      };
      if (editingId.value != null) {
        await _repo.updateSupplier(editingId.value!, data);
      } else {
        await _repo.createSupplier(data);
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
      await _repo.deleteSupplier(id);
      await load();
    } catch (e) {
      errorMsg.value = e.toString();
    }
  }
}
