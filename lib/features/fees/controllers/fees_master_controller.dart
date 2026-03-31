import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/fees_assignment_model.dart';
import '../models/fees_type_model.dart';
import '../repositories/fees_repository.dart';

class FeesMasterController extends GetxController {
  final FeesRepository _repo;
  FeesMasterController(this._repo);

  final assignments = <FeesAssignment>[].obs;
  final summary = Rx<FeesSummary>(FeesSummary.empty);
  final students = <StudentRef>[].obs;
  final types = <FeesType>[].obs;
  final academicYears = <AcademicYearRef>[].obs;
  final isLoading = true.obs;
  final editingId = Rx<int?>(null);

  // Filters
  final filterYearId = Rx<int?>(null);
  final filterStudentId = Rx<int?>(null);
  final filterStatus = Rx<String?>(null);
  final filterTypeId = Rx<int?>(null);

  // Form state
  final formYearId = Rx<int?>(null);
  final formStudentId = Rx<int?>(null);
  final formTypeId = Rx<int?>(null);
  final dueDateCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final discountCtrl = TextEditingController();

  static const List<String> statusOptions = ['unpaid', 'partial', 'paid'];

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    dueDateCtrl.dispose();
    amountCtrl.dispose();
    discountCtrl.dispose();
    super.onClose();
  }

  String yearName(int id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getStudents(),
        _repo.getTypes(),
        _repo.getAssignments(),
        _repo.getSummary(),
      ]);
      academicYears.assignAll(results[0] as List<AcademicYearRef>);
      students.assignAll(results[1] as List<StudentRef>);
      types.assignAll(results[2] as List<FeesType>);
      assignments.assignAll(results[3] as List<FeesAssignment>);
      summary.value = results[4] as FeesSummary;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters() async {
    isLoading.value = true;
    try {
      final params = <String, dynamic>{};
      if (filterYearId.value != null) {
        params['academic_year'] = filterYearId.value;
      }
      if (filterStudentId.value != null) {
        params['student'] = filterStudentId.value;
      }
      if (filterStatus.value != null) {
        params['status'] = filterStatus.value;
      }
      if (filterTypeId.value != null) {
        params['fees_type'] = filterTypeId.value;
      }

      final results = await Future.wait([
        _repo.getAssignments(params: params.isNotEmpty ? params : null),
        _repo.getSummary(params: params.isNotEmpty ? params : null),
      ]);
      assignments.assignAll(results[0] as List<FeesAssignment>);
      summary.value = results[1] as FeesSummary;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    filterYearId.value = null;
    filterStudentId.value = null;
    filterStatus.value = null;
    filterTypeId.value = null;
    loadAll();
  }

  void startCreate() {
    editingId.value = null;
    formYearId.value =
        academicYears.isNotEmpty ? academicYears.first.id : null;
    formStudentId.value = null;
    formTypeId.value = null;
    dueDateCtrl.text =
        DateTime.now().toIso8601String().split('T').first;
    amountCtrl.clear();
    discountCtrl.text = '0.00';
  }

  void startEdit(FeesAssignment a) {
    editingId.value = a.id;
    formYearId.value = a.academicYear;
    formStudentId.value = a.student;
    formTypeId.value = a.feesType;
    dueDateCtrl.text = a.dueDate;
    amountCtrl.text = a.amount.toStringAsFixed(2);
    discountCtrl.text = a.discountAmount.toStringAsFixed(2);
  }

  Future<void> saveAssignment() async {
    if (formYearId.value == null) {
      Get.snackbar('Validation', 'Academic year is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (formStudentId.value == null) {
      Get.snackbar('Validation', 'Student is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (formTypeId.value == null) {
      Get.snackbar('Validation', 'Fee type is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (dueDateCtrl.text.isEmpty) {
      Get.snackbar('Validation', 'Due date is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount < 0) {
      Get.snackbar('Validation', 'Enter a valid amount.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final discount =
        double.tryParse(discountCtrl.text.trim()) ?? 0.0;
    if (discount > amount) {
      Get.snackbar('Validation', 'Discount cannot exceed amount.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'academic_year': formYearId.value,
        'student': formStudentId.value,
        'fees_type': formTypeId.value,
        'due_date': dueDateCtrl.text.trim(),
        'amount': amount.toString(),
        'discount_amount': discount.toString(),
      };

      if (editingId.value == null) {
        final created = await _repo.createAssignment(data);
        assignments.add(created);
        Get.back();
        Get.snackbar('Success', 'Fee assignment created.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final updated =
            await _repo.updateAssignment(editingId.value!, data);
        final idx =
            assignments.indexWhere((a) => a.id == editingId.value);
        if (idx != -1) assignments[idx] = updated;
        Get.back();
        Get.snackbar('Success', 'Fee assignment updated.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      }

      // Refresh summary
      final params = <String, dynamic>{};
      if (filterYearId.value != null) {
        params['academic_year'] = filterYearId.value;
      }
      summary.value = await _repo.getSummary(
          params: params.isNotEmpty ? params : null);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAssignment(int id) async {
    isLoading.value = true;
    try {
      await _repo.deleteAssignment(id);
      assignments.removeWhere((a) => a.id == id);
      Get.snackbar('Deleted', 'Fee assignment deleted.',
          backgroundColor: const Color(0xFF0F766E),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);

      // Refresh summary
      summary.value = await _repo.getSummary();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
