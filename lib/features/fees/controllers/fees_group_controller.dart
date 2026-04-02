import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/fees_assignment_model.dart';
import '../models/fees_group_model.dart';
import '../repositories/fees_repository.dart';

class FeesGroupController extends GetxController {
  final FeesRepository _repo;
  FeesGroupController(this._repo);

  final groups = <FeesGroup>[].obs;
  final academicYears = <AcademicYearRef>[].obs;
  final isLoading = true.obs;
  final filterYearId = Rx<int?>(null);
  final editingId = Rx<int?>(null);

  // Form state
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formYearId = Rx<int?>(null);
  final formIsActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  List<FeesGroup> get filtered {
    if (filterYearId.value == null) return groups;
    return groups
        .where((g) => g.academicYear == filterYearId.value)
        .toList();
  }

  String yearName(int id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getGroups(),
      ]);
      academicYears.assignAll(results[0] as List<AcademicYearRef>);
      groups.assignAll(results[1] as List<FeesGroup>);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void startCreate() {
    editingId.value = null;
    nameCtrl.clear();
    descCtrl.clear();
    formYearId.value =
        academicYears.isNotEmpty ? academicYears.first.id : null;
    formIsActive.value = true;
  }

  void startEdit(FeesGroup g) {
    editingId.value = g.id;
    nameCtrl.text = g.name;
    descCtrl.text = g.description;
    formYearId.value = g.academicYear;
    formIsActive.value = g.isActive;
  }

  Future<void> saveGroup() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Group name is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (formYearId.value == null) {
      Get.snackbar('Validation', 'Academic year is required.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'academic_year': formYearId.value,
        'name': name,
        'description': descCtrl.text.trim(),
        'is_active': formIsActive.value,
      };

      if (editingId.value == null) {
        final created = await _repo.createGroup(data);
        groups.add(created);
        groups.sort((a, b) => a.name.compareTo(b.name));
        Get.back();
        Get.snackbar('Success', 'Fee group created.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final updated = await _repo.updateGroup(editingId.value!, data);
        final idx = groups.indexWhere((g) => g.id == editingId.value);
        if (idx != -1) groups[idx] = updated;
        groups.sort((a, b) => a.name.compareTo(b.name));
        Get.back();
        Get.snackbar('Success', 'Fee group updated.',
            backgroundColor: const Color(0xFF0F766E),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGroup(int id) async {
    isLoading.value = true;
    try {
      await _repo.deleteGroup(id);
      groups.removeWhere((g) => g.id == id);
      Get.snackbar('Deleted', 'Fee group deleted.',
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
}
