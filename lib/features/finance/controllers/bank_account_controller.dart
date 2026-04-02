import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/finance_models.dart';
import '../repositories/finance_repository.dart';

class BankAccountController extends GetxController {
  final FinanceRepository _repo;
  BankAccountController(this._repo);

  final accounts = <BankAccount>[].obs;
  final isLoading = false.obs;

  // Edit state
  final editingId = Rx<int?>(null);

  // Statement
  final statementLoading = false.obs;
  final statement = Rx<BankStatement?>(null);
  final stmtBankId = Rx<int?>(null);
  final stmtStartDate = Rx<DateTime?>(null);
  final stmtEndDate = Rx<DateTime?>(null);

  // Form
  final nameCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final balanceCtrl = TextEditingController();
  final formIsActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    bankNameCtrl.dispose();
    accountNumberCtrl.dispose();
    branchCtrl.dispose();
    balanceCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      accounts.value =
          await _repo.getBankAccounts(params: {'page_size': 200});
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void startCreate() {
    editingId.value = null;
    nameCtrl.clear();
    bankNameCtrl.clear();
    accountNumberCtrl.clear();
    branchCtrl.clear();
    balanceCtrl.clear();
    formIsActive.value = true;
  }

  void startEdit(BankAccount a) {
    editingId.value = a.id;
    nameCtrl.text = a.name;
    bankNameCtrl.text = a.bankName;
    accountNumberCtrl.text = a.accountNumber;
    branchCtrl.text = a.branch;
    balanceCtrl.text = a.currentBalance;
    formIsActive.value = a.isActive;
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    final bankName = bankNameCtrl.text.trim();
    final accNo = accountNumberCtrl.text.trim();
    if (name.isEmpty || bankName.isEmpty || accNo.isEmpty) {
      Get.snackbar(
        'Validation',
        'Name, bank name and account number are required.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final bal = balanceCtrl.text.trim();
      final data = {
        'name': name,
        'bank_name': bankName,
        'account_number': accNo,
        'branch': branchCtrl.text.trim(),
        'current_balance': bal.isEmpty ? '0.00' : bal,
        'is_active': formIsActive.value,
      };

      if (editingId.value == null) {
        final created = await _repo.createBankAccount(data);
        accounts.insert(0, created);
      } else {
        final updated =
            await _repo.updateBankAccount(editingId.value!, data);
        final idx =
            accounts.indexWhere((a) => a.id == editingId.value);
        if (idx >= 0) accounts[idx] = updated;
      }

      Get.back();
      Get.snackbar(
        'Success',
        editingId.value == null
            ? 'Bank account created.'
            : 'Bank account updated.',
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
      await _repo.deleteBankAccount(id);
      accounts.removeWhere((a) => a.id == id);
      Get.snackbar(
        'Deleted',
        'Bank account deleted.',
        backgroundColor: const Color(0xFF374151),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    }
  }

  void openStatementFor(int bankId) {
    stmtBankId.value = bankId;
    statement.value = null;
    stmtStartDate.value = null;
    stmtEndDate.value = null;
  }

  Future<void> loadStatement() async {
    final id = stmtBankId.value;
    if (id == null) return;
    statementLoading.value = true;
    try {
      final params = <String, dynamic>{};
      if (stmtStartDate.value != null) {
        params['start_date'] =
            '${stmtStartDate.value!.year}-${stmtStartDate.value!.month.toString().padLeft(2, '0')}-${stmtStartDate.value!.day.toString().padLeft(2, '0')}';
      }
      if (stmtEndDate.value != null) {
        params['end_date'] =
            '${stmtEndDate.value!.year}-${stmtEndDate.value!.month.toString().padLeft(2, '0')}-${stmtEndDate.value!.day.toString().padLeft(2, '0')}';
      }
      statement.value = await _repo.getBankStatement(
          id, params: params.isEmpty ? null : params);
    } catch (e) {
      _showError(e);
    } finally {
      statementLoading.value = false;
    }
  }

  String bankName(int id) {
    return accounts.firstWhereOrNull((b) => b.id == id)?.name ??
        'Bank #$id';
  }

  void _showError(Object e) {
    Get.snackbar(
      'Error',
      ApiError.extract(e),
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
