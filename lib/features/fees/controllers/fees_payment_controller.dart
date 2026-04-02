import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/fees_assignment_model.dart';
import '../models/fees_payment_model.dart';
import '../repositories/fees_repository.dart';

class FeesPaymentController extends GetxController {
  final FeesRepository _repo;
  FeesPaymentController(this._repo);

  // ── State ──────────────────────────────────────────────────────────────────
  final payments = <FeesPayment>[].obs;
  final allAssignments = <FeesAssignment>[].obs;
  final isLoading = true.obs;
  final receipt = Rx<FeesReceipt?>(null);

  // Form state
  final formAssignmentId = Rx<int?>(null);
  final formMethod = 'cash'.obs;
  final amountCtrl = TextEditingController();
  final transRefCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final paidAtCtrl = TextEditingController();

  static const List<String> methodOptions = [
    'cash',
    'bank',
    'online',
    'wallet',
    'cheque',
  ];

  static const Map<String, String> methodLabels = {
    'cash': 'Cash',
    'bank': 'Bank',
    'online': 'Online',
    'wallet': 'Wallet',
    'cheque': 'Cheque',
  };

  FeesAssignment? get selectedAssignment =>
      allAssignments.firstWhereOrNull(
          (a) => a.id == formAssignmentId.value);

  String assignmentLabel(FeesAssignment a) {
    final name = a.studentName.isNotEmpty ? a.studentName : 'Student #${a.student}';
    final type = a.feesTypeName.isNotEmpty ? a.feesTypeName : 'Type #${a.feesType}';
    return '#${a.id} – $name – $type – Due: ₹${a.dueAmount.toStringAsFixed(2)}';
  }

  @override
  void onInit() {
    super.onInit();
    paidAtCtrl.text = DateTime.now().toIso8601String().split('T').first;
    loadAll();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    transRefCtrl.dispose();
    noteCtrl.dispose();
    paidAtCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getPayments(params: {'page_size': 2000}),
        _repo.getAssignments(params: {'page_size': 2000}),
      ]);
      payments.assignAll(results[0] as List<FeesPayment>);
      allAssignments.assignAll(results[1] as List<FeesAssignment>);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void onAssignmentChanged(int? assignmentId) {
    formAssignmentId.value = assignmentId;
    final a = selectedAssignment;
    if (a != null) {
      amountCtrl.text = a.dueAmount.toStringAsFixed(2);
    } else {
      amountCtrl.clear();
    }
  }

  void resetForm() {
    formAssignmentId.value = null;
    formMethod.value = 'cash';
    amountCtrl.clear();
    transRefCtrl.clear();
    noteCtrl.clear();
    paidAtCtrl.text =
        DateTime.now().toIso8601String().split('T').first;
  }

  Future<void> recordPayment() async {
    if (formAssignmentId.value == null) {
      Get.snackbar('Validation', 'Please select a fee assignment.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Validation', 'Enter a valid payment amount.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final due = selectedAssignment?.dueAmount ?? 0.0;
    if (amount > due) {
      Get.snackbar(
          'Validation',
          'Amount cannot exceed due amount (${due.toStringAsFixed(2)}).',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (paidAtCtrl.text.isEmpty) {
      Get.snackbar('Validation', 'Please enter payment date.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final assignment = selectedAssignment!;
      final data = {
        'assignment': formAssignmentId.value,
        'student': assignment.student,
        'amount_paid': amount.toString(),
        'method': formMethod.value,
        'transaction_reference': transRefCtrl.text.trim(),
        'note': noteCtrl.text.trim(),
        'paid_at': '${paidAtCtrl.text.trim()}T00:00:00Z',
      };

      final created = await _repo.createPayment(data);
      payments.insert(0, created);
      resetForm();
      // Reload assignments to reflect updated due amounts
      allAssignments.assignAll(await _repo.getAssignments(
          params: {'page_size': 2000}));

      Get.snackbar('Success', 'Payment recorded successfully.',
          backgroundColor: const Color(0xFF0F766E),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePayment(int id) async {
    isLoading.value = true;
    try {
      await _repo.deletePayment(id);
      payments.removeWhere((p) => p.id == id);
      // Reload assignments to reflect restored due amounts
      allAssignments.assignAll(await _repo.getAssignments(
          params: {'page_size': 2000}));
      Get.snackbar('Deleted', 'Payment deleted.',
          backgroundColor: const Color(0xFF0F766E),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReceipt(int paymentId) async {
    receipt.value = null;
    isLoading.value = true;
    try {
      receipt.value = await _repo.getReceipt(paymentId);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    isLoading.value = true;
    try {
      payments.assignAll(await _repo.getPayments());
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
