import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/role_model.dart';
import '../repositories/access_control_repository.dart';

class RoleController extends GetxController {
  final AccessControlRepository repository;

  RoleController({required this.repository});

  final RxList<RoleItem> roles = <RoleItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final RxnInt editingRoleId = RxnInt();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoles();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadRoles() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fetchedRoles = await repository.getRoles();
      roles.assignAll(fetchedRoles);
    } catch (e) {
      errorMessage.value = 'Unable to load role list.';
    } finally {
      isLoading.value = false;
    }
  }

  List<RoleItem> get filteredRoles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return roles;
    return roles.where((r) => r.name.toLowerCase().contains(query)).toList();
  }

  void resetForm() {
    editingRoleId.value = null;
    nameController.clear();
  }

  void startEdit(RoleItem role) {
    editingRoleId.value = role.id;
    nameController.text = role.name;
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Role name is required.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSaving.value = true;
    errorMessage.value = '';
    try {
      if (editingRoleId.value != null) {
        await repository.updateRole(editingRoleId.value!, name);
        Get.snackbar('Success', 'Role updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await repository.createRole(name);
        Get.snackbar('Success', 'Role created successfully', backgroundColor: Colors.green, colorText: Colors.white);
      }
      resetForm();
      await loadRoles();
    } catch (e) {
      Get.snackbar('Error', 'Unable to save role.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRole(int id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this role?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      errorMessage.value = '';
      await repository.deleteRole(id);
      if (editingRoleId.value == id) resetForm();
      Get.snackbar('Success', 'Role deleted successfully', backgroundColor: Colors.green, colorText: Colors.white);
      await loadRoles();
    } catch (e) {
      Get.snackbar('Error', 'Unable to delete role.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
