import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/due_fees_model.dart';
import '../models/login_access_model.dart' show Option, SectionOption;
import '../repositories/access_control_repository.dart';

class DueFeesPermissionController extends GetxController {
  final AccessControlRepository repository;

  DueFeesPermissionController({required this.repository});

  final RxList<Option> classes = <Option>[].obs;
  final RxList<SectionOption> sections = <SectionOption>[].obs;

  final RxnString selectedClassId = RxnString();
  final RxnString selectedSectionId = RxnString();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController admissionNoController = TextEditingController();

  final RxList<DueUserRow> users = <DueUserRow>[].obs;

  final RxBool isLoadingCriteria = true.obs;
  final RxBool isLoading = false.obs;
  final RxnInt actionUserId = RxnInt();
  final RxString errorMessage = ''.obs;

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
    super.onClose();
  }

  Future<void> loadCriteria() async {
    isLoadingCriteria.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.getDueFeesCriteria();
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
    selectedSectionId.value = null;
  }

  Future<void> searchUsers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fetched = await repository.getDueFeesUsers(
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        name: nameController.text.trim(),
        admissionNo: admissionNoController.text.trim(),
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
      await repository.toggleDueFeesPermission(userId, status);
      
      // Update local state
      final index = users.indexWhere((u) => u.studentUserId == userId || u.parentUserId == userId);
      if (index != -1) {
        final row = users[index];
        if (row.studentUserId == userId) {
          users[index] = DueUserRow(
            admissionNo: row.admissionNo, rollNo: row.rollNo, studentName: row.studentName,
            className: row.className, sectionName: row.sectionName, dueAmount: row.dueAmount,
            studentUserId: row.studentUserId, studentAccessStatus: status,
            parentName: row.parentName, parentUserId: row.parentUserId, parentAccessStatus: row.parentAccessStatus,
          );
        } else if (row.parentUserId == userId) {
          users[index] = DueUserRow(
            admissionNo: row.admissionNo, rollNo: row.rollNo, studentName: row.studentName,
            className: row.className, sectionName: row.sectionName, dueAmount: row.dueAmount,
            studentUserId: row.studentUserId, studentAccessStatus: row.studentAccessStatus,
            parentName: row.parentName, parentUserId: row.parentUserId, parentAccessStatus: status,
          );
        }
      }
      Get.snackbar('Success', 'Due fees login permission updated.', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to update due fees permission.'), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      actionUserId.value = null;
    }
  }
}
