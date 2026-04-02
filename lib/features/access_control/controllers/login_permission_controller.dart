import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/login_access_model.dart';
import '../repositories/access_control_repository.dart';

class LoginPermissionController extends GetxController {
  final AccessControlRepository repository;

  LoginPermissionController({required this.repository});

  final RxList<Option> roles = <Option>[].obs;
  final RxList<Option> classes = <Option>[].obs;
  final RxList<SectionOption> sections = <SectionOption>[].obs;

  final RxnString selectedRoleId = RxnString();
  final RxnString selectedClassId = RxnString();
  final RxnString selectedSectionId = RxnString();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController admissionNoController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();

  final RxList<LoginUserRow> users = <LoginUserRow>[].obs;
  
  // Track passwords for each user/parent by ID
  final RxMap<int, String> passwordMap = <int, String>{}.obs;

  final RxBool isLoadingCriteria = true.obs;
  final RxBool isLoading = false.obs;
  final RxnInt actionUserId = RxnInt();
  final RxString errorMessage = ''.obs;

  bool get isStudentRole {
    if (selectedRoleId.value == null) return false;
    final role = roles.firstWhereOrNull((r) => r.id.toString() == selectedRoleId.value);
    return role?.name.toLowerCase().contains('student') ?? false;
  }

  List<SectionOption> get filteredSections {
    if (selectedClassId.value == null) return sections;
    return sections.where((s) => s.classId.toString() == selectedClassId.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCriteria();
  }

  @override
  void onClose() {
    nameController.dispose();
    admissionNoController.dispose();
    rollNoController.dispose();
    super.onClose();
  }

  Future<void> loadCriteria() async {
    isLoadingCriteria.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.getLoginCriteria();
      roles.assignAll(response.roles);
      classes.assignAll(response.classes);
      sections.assignAll(response.sections);
    } catch (e) {
      errorMessage.value = ApiError.extract(e, 'Failed to load criteria.');
    } finally {
      isLoadingCriteria.value = false;
    }
  }

  void onClassChanged(String? val) {
    selectedClassId.value = val;
    selectedSectionId.value = null; // reset section
  }

  Future<void> searchUsers() async {
    if (selectedRoleId.value == null) {
      Get.snackbar('Error', 'Select role first.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (isStudentRole && selectedClassId.value == null) {
      Get.snackbar('Error', 'Select class for student role.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fetched = await repository.getLoginUsers(
        roleId: selectedRoleId.value!,
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        name: nameController.text.trim(),
        admissionNo: admissionNoController.text.trim(),
        rollNo: rollNoController.text.trim(),
      );
      users.assignAll(fetched);
    } catch (e) {
      errorMessage.value = ApiError.extract(e, 'Failed to load users.');
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAccess(int userId, bool status) async {
    actionUserId.value = userId;
    try {
      await repository.toggleLoginPermission(userId, status);
      
      // Update local state
      final index = users.indexWhere((u) => u.userId == userId || u.parentUserId == userId);
      if (index != -1) {
        final row = users[index];
        if (row.userId == userId) {
          users[index] = LoginUserRow(
            userId: row.userId, username: row.username, name: row.name, email: row.email,
            roleId: row.roleId, roleName: row.roleName, accessStatus: status,
            staffNo: row.staffNo, admissionNo: row.admissionNo, rollNo: row.rollNo,
            className: row.className, sectionName: row.sectionName,
            parentUserId: row.parentUserId, parentUsername: row.parentUsername,
            parentName: row.parentName, parentEmail: row.parentEmail,
            parentAccessStatus: row.parentAccessStatus,
          );
        } else if (row.parentUserId == userId) {
          users[index] = LoginUserRow(
            userId: row.userId, username: row.username, name: row.name, email: row.email,
            roleId: row.roleId, roleName: row.roleName, accessStatus: row.accessStatus,
            staffNo: row.staffNo, admissionNo: row.admissionNo, rollNo: row.rollNo,
            className: row.className, sectionName: row.sectionName,
            parentUserId: row.parentUserId, parentUsername: row.parentUsername,
            parentName: row.parentName, parentEmail: row.parentEmail,
            parentAccessStatus: status,
          );
        }
      }
      Get.snackbar('Success', 'Login permission updated.', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to update permission.'), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      actionUserId.value = null;
    }
  }

  Future<void> resetPassword(int userId, bool isDefault) async {
    actionUserId.value = userId;
    try {
      final entered = (passwordMap[userId] ?? '').trim();
      final pwd = isDefault ? '123456' : entered;
      if (pwd.isEmpty) {
        Get.snackbar('Error', 'Enter password before update.', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      await repository.resetPassword(userId, pwd);
      Get.snackbar('Success', isDefault ? 'Password reset to 123456.' : 'Password updated.', backgroundColor: Colors.green, colorText: Colors.white);
      
      if (!isDefault) {
        passwordMap[userId] = '';
      }
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to reset password.'), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      actionUserId.value = null;
    }
  }
}
