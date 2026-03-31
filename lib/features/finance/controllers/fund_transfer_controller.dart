import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../repositories/finance_repository.dart';

class FundTransferController extends GetxController {
  final FinanceRepository _repo;
  FundTransferController(this._repo);

  final transfers = <FundTransfer>[].obs;
  final bankAccounts = <BankAccount>[].obs;
  final isLoading = false.obs;

  // Form
  final formFromBankId = Rx<int?>(null);
  final formToBankId = Rx<int?>(null);
  final amountCtrl = TextEditingController();
  final formDate = Rx<DateTime>(DateTime.now());
  final referenceCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  String get formDateDisplay =>
      DateFormat('dd/MM/yyyy').format(formDate.value);
  String get formDateApi =>
      DateFormat('yyyy-MM-dd').format(formDate.value);

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    referenceCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getFundTransfers(params: {'page_size': 500}),
        _repo.getBankAccounts(params: {'page_size': 200}),
      ]);
      transfers.value = results[0] as List<FundTransfer>;
      bankAccounts.value = results[1] as List<BankAccount>;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void startCreate() {
    formFromBankId.value = null;
    formToBankId.value = null;
    amountCtrl.clear();
    formDate.value = DateTime.now();
    referenceCtrl.clear();
    noteCtrl.clear();
  }

  Future<void> save() async {
    if (formFromBankId.value == null || formToBankId.value == null) {
      Get.snackbar(
        'Validation',
        'Please select both source and destination banks.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (formFromBankId.value == formToBankId.value) {
      Get.snackbar(
        'Validation',
        'Source and destination must be different banks.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final amount = amountCtrl.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null) {
      Get.snackbar(
        'Validation',
        'Please enter a valid amount.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'from_bank': formFromBankId.value,
        'to_bank': formToBankId.value,
        'amount': amount,
        'transfer_date': formDateApi,
        'reference_no': referenceCtrl.text.trim(),
        'note': noteCtrl.text.trim(),
      };
      final created = await _repo.createFundTransfer(data);
      transfers.insert(0, created);
      // Reload to get updated balances
      await loadAll();
      Get.back();
      Get.snackbar(
        'Success',
        'Fund transfer completed.',
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteFundTransfer(id);
      transfers.removeWhere((t) => t.id == id);
      Get.snackbar(
        'Deleted',
        'Transfer deleted.',
        backgroundColor: const Color(0xFF374151),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    }
  }

  String bankName(int id) {
    return bankAccounts.firstWhereOrNull((b) => b.id == id)?.name ??
        'Bank #$id';
  }

  void _showError(Object e) {
    Get.snackbar(
      'Error',
      e.toString(),
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
