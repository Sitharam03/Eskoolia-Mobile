import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/fees_assignment_model.dart';
import '../models/fees_group_model.dart';
import '../models/fees_type_model.dart';
import '../repositories/fees_repository.dart';

class FeesTypeController extends GetxController {
  final FeesRepository _repo;
  FeesTypeController(this._repo);

  final types = <FeesType>[].obs;
  final groups = <FeesGroup>[].obs;
  final academicYears = <AcademicYearRef>[].obs;
  final isLoading = true.obs;
  final filterYearId = Rx<int?>(null);
  final filterGroupId = Rx<int?>(null);
  final editingId = Rx<int?>(null);

  // Form state
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formYearId = Rx<int?>(null);
  final formGroupId = Rx<int?>(null);
  final formIsActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  List<FeesType> get filtered {
    var list = types.toList();
    if (filterYearId.value != null) {
      list = list.where((t) => t.academicYear == filterYearId.value).toList();
    }
    if (filterGroupId.value != null) {
      list = list.where((t) => t.feesGroup == filterGroupId.value).toList();
    }
    return list;
  }

  String yearName(int id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';

  String groupName(int id) =>
      groups.firstWhereOrNull((g) => g.id == id)?.name ?? '-';

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getGroups(),
        _repo.getTypes(),
      ]);
      academicYears.assignAll(results[0] as List<AcademicYearRef>);
      groups.assignAll(results[1] as List<FeesGroup>);
      types.assignAll(results[2] as List<FeesType>);
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
    editingId.value = null;
    nameCtrl.clear();
    amountCtrl.clear();
    descCtrl.clear();
    formYearId.value =
        academicYears.isNotEmpty ? academicYears.first.id : null;
    formGroupId.value = null;
    formIsActive.value = true;
  }

  void startEdit(FeesType t) {
    editingId.value = t.id;
    nameCtrl.text = t.name;
    amountCtrl.text = t.amount.toStringAsFixed(2);
    descCtrl.text = t.description;
    formYearId.value = t.academicYear;
    formGroupId.value = t.feesGroup;
    formIsActive.value = t.isActive;
  }

  Future<void> saveType() async {
    final name = nameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim());

    if (formYearId.value == null) {
      Get.snackbar('Validation', 'Academic year is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (formGroupId.value == null) {
      Get.snackbar('Validation', 'Fee group is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Fee type name is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (amount == null || amount < 0) {
      Get.snackbar('Validation', 'Enter a valid amount.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'academic_year': formYearId.value,
        'fees_group': formGroupId.value,
        'name': name,
        'amount': amount.toString(),
        'description': descCtrl.text.trim(),
        'is_active': formIsActive.value,
      };

      if (editingId.value == null) {
        final created = await _repo.createType(data);
        types.add(created);
        types.sort((a, b) => a.name.compareTo(b.name));
        Get.snackbar('Success', 'Fee type created.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final updated = await _repo.updateType(editingId.value!, data);
        final idx = types.indexWhere((t) => t.id == editingId.value);
        if (idx != -1) types[idx] = updated;
        types.sort((a, b) => a.name.compareTo(b.name));
        Get.snackbar('Success', 'Fee type updated.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteType(int id) async {
    isLoading.value = true;
    try {
      await _repo.deleteType(id);
      types.removeWhere((t) => t.id == id);
      Get.snackbar('Deleted', 'Fee type deleted.',
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
}
