import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/finance_models.dart';
import '../repositories/finance_repository.dart';

class ChartOfAccountsController extends GetxController {
  final FinanceRepository _repo;
  ChartOfAccountsController(this._repo);

  final accounts = <ChartOfAccount>[].obs;
  final isLoading = false.obs;

  // Filter
  final filterType = Rx<String?>(null);

  // Edit state
  final editingId = Rx<int?>(null);

  // Form
  final codeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formType = Rx<String?>('asset');
  final formIsActive = true.obs;

  List<ChartOfAccount> get filtered {
    if (filterType.value == null) return accounts;
    return accounts
        .where((a) => a.accountType == filterType.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      accounts.value = await _repo.getChartOfAccounts(
          params: {'page_size': 500});
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void startCreate() {
    editingId.value = null;
    codeCtrl.clear();
    nameCtrl.clear();
    descCtrl.clear();
    formType.value = 'asset';
    formIsActive.value = true;
  }

  void startEdit(ChartOfAccount a) {
    editingId.value = a.id;
    codeCtrl.text = a.code;
    nameCtrl.text = a.name;
    descCtrl.text = a.description;
    formType.value = a.accountType;
    formIsActive.value = a.isActive;
  }

  Future<void> save() async {
    final code = codeCtrl.text.trim();
    final name = nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty || formType.value == null) {
      Get.snackbar(
        'Validation',
        'Code, name, and type are required.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'code': code,
        'name': name,
        'account_type': formType.value,
        'description': descCtrl.text.trim(),
        'is_active': formIsActive.value,
      };

      if (editingId.value == null) {
        final created = await _repo.createChartOfAccount(data);
        accounts.insert(0, created);
      } else {
        final updated =
            await _repo.updateChartOfAccount(editingId.value!, data);
        final idx = accounts.indexWhere((a) => a.id == editingId.value);
        if (idx >= 0) accounts[idx] = updated;
      }

      Get.back();
      Get.snackbar(
        'Success',
        editingId.value == null ? 'Account created.' : 'Account updated.',
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
      await _repo.deleteChartOfAccount(id);
      accounts.removeWhere((a) => a.id == id);
      Get.snackbar(
        'Deleted',
        'Account deleted.',
        backgroundColor: const Color(0xFF374151),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    }
  }

  String accountLabel(int id) {
    final a = accounts.firstWhereOrNull((x) => x.id == id);
    return a != null ? '${a.code} – ${a.name}' : 'Account #$id';
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
