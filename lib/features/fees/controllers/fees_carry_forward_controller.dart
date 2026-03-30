import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/fees_assignment_model.dart';
import '../repositories/fees_repository.dart';

class FeesCarryForwardController extends GetxController {
  final FeesRepository _repo;
  FeesCarryForwardController(this._repo);

  final academicYears = <AcademicYearRef>[].obs;
  final fromYearId = Rx<int?>(null);
  final toYearId = Rx<int?>(null);
  final dueDateCtrl = TextEditingController();
  final isLoading = true.obs;
  final result = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    dueDateCtrl.text =
        DateTime.now().toIso8601String().split('T').first;
    _loadYears();
  }

  @override
  void onClose() {
    dueDateCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadYears() async {
    try {
      academicYears.assignAll(await _repo.getAcademicYears());
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> carryForward() async {
    if (fromYearId.value == null || toYearId.value == null) {
      Get.snackbar('Validation', 'Please select both academic years.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (fromYearId.value == toYearId.value) {
      Get.snackbar(
          'Validation', 'From and To years must be different.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    result.value = null;
    try {
      final data = <String, dynamic>{
        'from_academic_year': fromYearId.value,
        'to_academic_year': toYearId.value,
      };
      if (dueDateCtrl.text.trim().isNotEmpty) {
        data['due_date'] = dueDateCtrl.text.trim();
      }

      result.value = await _repo.carryForward(data);
      Get.snackbar('Success', 'Carry forward completed.',
          backgroundColor: const Color(0xFF0F766E),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    fromYearId.value = null;
    toYearId.value = null;
    dueDateCtrl.text =
        DateTime.now().toIso8601String().split('T').first;
    result.value = null;
  }
}
