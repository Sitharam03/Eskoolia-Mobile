import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/role_model.dart';
import '../models/permission_model.dart';
import '../repositories/access_control_repository.dart';

class AssignPermissionController extends GetxController {
  final AccessControlRepository repository;

  AssignPermissionController({required this.repository});

  final RxList<RoleItem> roles = <RoleItem>[].obs;
  final RxList<ModuleNode> modules = <ModuleNode>[].obs;
  final RxnString activeRoleName = RxnString();
  final RxnInt selectedRoleId = RxnInt();

  // Selected permission IDs
  final RxSet<int> selectedPermissionIds = <int>{}.obs;
  
  // Expanded modules state
  final RxMap<String, bool> expandedModules = <String, bool>{}.obs;

  final RxBool isLoadingRoles = true.obs;
  final RxBool isLoadingTree = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final paramId = Get.parameters['id'];
    if (paramId != null) {
      selectedRoleId.value = int.tryParse(paramId);
    }
    loadRoles();
  }

  Future<void> loadRoles() async {
    isLoadingRoles.value = true;
    errorMessage.value = '';
    try {
      final fetchedRoles = await repository.getRoles();
      roles.assignAll(fetchedRoles);
      
      // Select first if none selected
      if (selectedRoleId.value == null && roles.isNotEmpty) {
        selectedRoleId.value = roles.first.id;
      }
      
      if (selectedRoleId.value != null) {
        _updateActiveRoleName();
        await loadTree(selectedRoleId.value!);
      }
    } catch (e) {
      errorMessage.value = ApiError.extract(e, 'Failed to load roles.');
    } finally {
      isLoadingRoles.value = false;
    }
  }

  void _updateActiveRoleName() {
    try {
      final role = roles.firstWhere((r) => r.id == selectedRoleId.value);
      activeRoleName.value = role.name;
    } catch (_) {
      activeRoleName.value = null;
    }
  }

  Future<void> loadTree(int roleId) async {
    isLoadingTree.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.getPermissionTree(roleId);
      modules.assignAll(response.modules);
      
      // Expand first module by default
      expandedModules.clear();
      if (modules.isNotEmpty) {
        expandedModules[modules.first.module] = true;
      }

      // Populate selected IDs
      final Set<int> nextSelected = {};
      for (final module in response.modules) {
        for (final permission in module.permissions) {
          if (permission.selected) {
            nextSelected.add(permission.id);
          }
        }
      }
      selectedPermissionIds.assignAll(nextSelected);
    } catch (e) {
      errorMessage.value = ApiError.extract(e, 'Failed to load permission list.');
      modules.clear();
      selectedPermissionIds.clear();
    } finally {
      isLoadingTree.value = false;
    }
  }

  void onRoleChanged(int? newRoleId) {
    if (newRoleId != null) {
      selectedRoleId.value = newRoleId;
      _updateActiveRoleName();
      loadTree(newRoleId);
    }
  }

  void togglePermission(int id) {
    if (selectedPermissionIds.contains(id)) {
      selectedPermissionIds.remove(id);
    } else {
      selectedPermissionIds.add(id);
    }
  }

  void toggleModule(ModuleNode module, bool checked) {
    for (final permission in module.permissions) {
      if (checked) {
        selectedPermissionIds.add(permission.id);
      } else {
        selectedPermissionIds.remove(permission.id);
      }
    }
  }

  void toggleModuleExpanded(String moduleKey) {
    final current = expandedModules[moduleKey] ?? false;
    expandedModules[moduleKey] = !current;
  }

  Future<void> save() async {
    if (selectedRoleId.value == null) return;
    
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await repository.assignPermissions(
        selectedRoleId.value!,
        selectedPermissionIds.toList(),
      );
      Get.snackbar('Success', 'Permissions updated successfully.', backgroundColor: Colors.green, colorText: Colors.white);
      await loadTree(selectedRoleId.value!);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to update permissions.'), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  String prettyModuleName(String value) {
    return value
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }
}
