import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_group_model.dart';
import '../repositories/students_repository.dart';

class StudentGroupController extends GetxController {
  final _repo = StudentsRepository();

  final groups = <StudentGroup>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final editingId = Rxn<int>();
  final searchQuery = ''.obs;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    try {
      groups.value = await _repo.getGroups();
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load groups'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentGroup> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return groups;
    return groups
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            g.description.toLowerCase().contains(q))
        .toList();
  }

  void startEdit(StudentGroup group) {
    editingId.value = group.id;
    nameCtrl.text = group.name;
    descriptionCtrl.text = group.description;
  }

  void resetForm() {
    editingId.value = null;
    nameCtrl.clear();
    descriptionCtrl.clear();
  }

  Future<bool> save() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Group name is required',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isSaving.value = true;
    try {
      final data = {
        'name': nameCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await _repo.updateGroup(editingId.value!, data);
        Get.snackbar('Success', 'Group updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await _repo.createGroup(data);
        Get.snackbar('Success', 'Group created',
            snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
      await loadGroups();
      return true;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to save group'),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteGroup(id);
      groups.removeWhere((g) => g.id == id);
      Get.snackbar('Deleted', 'Group removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to delete group'),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
