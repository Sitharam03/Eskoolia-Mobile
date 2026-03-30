import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/library_models.dart';
import '../repositories/library_repository.dart';

class LibraryMemberController extends GetxController {
  final _repo = LibraryRepository();

  final members = <LibraryMember>[].obs;
  final students = <LibraryStudent>[].obs;
  final staffList = <LibraryStaff>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  // Form
  final memberType = 'student'.obs; // 'student' | 'staff'
  final selectedStudentId = Rx<int?>(null);
  final selectedStaffId = Rx<int?>(null);
  final cardNoCtrl = TextEditingController();
  final isActive = true.obs;
  final editingId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    cardNoCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final results = await Future.wait([
        _repo.getMembers(),
        _repo.getStudents(),
        _repo.getStaff(),
      ]);
      members.value = results[0] as List<LibraryMember>;
      students.value = results[1] as List<LibraryStudent>;
      staffList.value = results[2] as List<LibraryStaff>;
    } catch (_) {
      errorMsg.value = 'Unable to load members.';
    } finally {
      isLoading.value = false;
    }
  }

  String memberDisplayName(LibraryMember m) {
    if (m.isStudent) {
      // Use embedded name from API response first (nested object case)
      if (m.embeddedStudentName != null && m.embeddedStudentName!.isNotEmpty) {
        return m.embeddedStudentName!;
      }
      // Fall back to lookup in loaded students list
      final s = students.firstWhereOrNull((s) => s.id == m.studentId);
      return s != null ? s.fullName : (m.studentId != null ? 'Student #${m.studentId}' : 'Unknown Student');
    } else {
      if (m.embeddedStaffName != null && m.embeddedStaffName!.isNotEmpty) {
        return m.embeddedStaffName!;
      }
      final s = staffList.firstWhereOrNull((s) => s.id == m.staffId);
      return s != null ? s.fullName : (m.staffId != null ? 'Staff #${m.staffId}' : 'Unknown Staff');
    }
  }

  void setMemberType(String type) {
    memberType.value = type;
    selectedStudentId.value = null;
    selectedStaffId.value = null;
  }

  void startEdit(LibraryMember m) {
    editingId.value = m.id;
    memberType.value = m.memberType;
    selectedStudentId.value = m.studentId;
    selectedStaffId.value = m.staffId;
    cardNoCtrl.text = m.cardNo;
    isActive.value = m.isActive;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    memberType.value = 'student';
    selectedStudentId.value = null;
    selectedStaffId.value = null;
    cardNoCtrl.clear();
    isActive.value = true;
    errorMsg.value = '';
  }

  Future<void> save() async {
    final cardNo = cardNoCtrl.text.trim();
    if (cardNo.isEmpty) {
      errorMsg.value = 'Card number is required.';
      return;
    }
    if (memberType.value == 'student' && selectedStudentId.value == null) {
      errorMsg.value = 'Student is required for student member type.';
      return;
    }
    if (memberType.value == 'staff' && selectedStaffId.value == null) {
      errorMsg.value = 'Staff is required for staff member type.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'member_type': memberType.value,
        'student': memberType.value == 'student' ? selectedStudentId.value : null,
        'staff': memberType.value == 'staff' ? selectedStaffId.value : null,
        'card_no': cardNo,
        'is_active': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateMember(editingId.value!, payload);
      } else {
        await _repo.createMember(payload);
      }
      cancelEdit();
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to save member.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteMember(id);
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to delete member.';
    }
  }
}
