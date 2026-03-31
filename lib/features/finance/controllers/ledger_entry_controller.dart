import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../repositories/finance_repository.dart';

class LedgerEntryController extends GetxController {
  final FinanceRepository _repo;
  LedgerEntryController(this._repo);

  final entries = <LedgerEntry>[].obs;
  final accounts = <ChartOfAccount>[].obs;
  final academicYears = <FinAcademicYear>[].obs;

  final isLoading = false.obs;
  final summaryLoading = false.obs;
  final trialBalanceLoading = false.obs;

  final summary = Rx<LedgerSummary?>(null);
  final trialBalance = Rx<TrialBalance?>(null);

  // Filters
  final filterType = Rx<String?>(null);
  final filterAccountId = Rx<int?>(null);

  // Form
  final formYearId = Rx<int?>(null);
  final formAccountId = Rx<int?>(null);
  final formType = Rx<String?>('debit');
  final amountCtrl = TextEditingController();
  final formDate = Rx<DateTime>(DateTime.now());
  final referenceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String get formDateDisplay =>
      DateFormat('dd/MM/yyyy').format(formDate.value);
  String get formDateApi =>
      DateFormat('yyyy-MM-dd').format(formDate.value);

  List<LedgerEntry> get filtered {
    return entries.where((e) {
      if (filterType.value != null && e.entryType != filterType.value) {
        return false;
      }
      if (filterAccountId.value != null &&
          e.accountId != filterAccountId.value) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    referenceCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getLedgerEntries(params: {'page_size': 500}),
        _repo.getChartOfAccounts(params: {'page_size': 500}),
        _repo.getAcademicYears(),
      ]);
      entries.value = results[0] as List<LedgerEntry>;
      accounts.value = results[1] as List<ChartOfAccount>;
      academicYears.value = results[2] as List<FinAcademicYear>;
      _loadSummaryQuietly();
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSummaryQuietly() async {
    summaryLoading.value = true;
    try {
      summary.value = await _repo.getLedgerSummary();
    } catch (_) {
      // summary is non-blocking
    } finally {
      summaryLoading.value = false;
    }
  }

  Future<void> loadTrialBalance() async {
    trialBalanceLoading.value = true;
    try {
      trialBalance.value = await _repo.getTrialBalance();
    } catch (e) {
      _showError(e);
    } finally {
      trialBalanceLoading.value = false;
    }
  }

  void startCreate() {
    formYearId.value = null;
    formAccountId.value = null;
    formType.value = 'debit';
    amountCtrl.clear();
    formDate.value = DateTime.now();
    referenceCtrl.clear();
    descCtrl.clear();
  }

  Future<void> save() async {
    final amount = amountCtrl.text.trim();
    if (formAccountId.value == null ||
        amount.isEmpty ||
        double.tryParse(amount) == null) {
      Get.snackbar(
        'Validation',
        'Account and a valid amount are required.',
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final data = <String, dynamic>{
        'account': formAccountId.value,
        'entry_type': formType.value ?? 'debit',
        'amount': amount,
        'entry_date': formDateApi,
        'reference_no': referenceCtrl.text.trim(),
        'description': descCtrl.text.trim(),
      };
      if (formYearId.value != null) data['academic_year'] = formYearId.value;

      final created = await _repo.createLedgerEntry(data);
      entries.insert(0, created);
      Get.back();
      _loadSummaryQuietly();
      Get.snackbar(
        'Success',
        'Ledger entry added.',
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
      await _repo.deleteLedgerEntry(id);
      entries.removeWhere((e) => e.id == id);
      _loadSummaryQuietly();
      Get.snackbar(
        'Deleted',
        'Entry deleted.',
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

  String yearName(int? id) {
    if (id == null) return '–';
    return academicYears.firstWhereOrNull((y) => y.id == id)?.title ??
        'Year #$id';
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
