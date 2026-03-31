import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrLeaveDefineController extends GetxController {
  final _repo = HrRepository();
  final defines = <LeaveDefine>[].obs;
  final roles = <HrRole>[].obs;
  final staff = <Staff>[].obs;
  final leaveTypes = <LeaveType>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final editingId = Rx<int?>(null);
  final daysCtrl = TextEditingController(text: '0');
  final selectedRoleId = Rx<int?>(null);
  final selectedStaffId = Rx<int?>(null);
  final selectedLeaveTypeId = Rx<int?>(null);

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() { daysCtrl.dispose(); super.onClose(); }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getLeaveDefines(), _repo.getRoles(),
        _repo.getStaff(), _repo.getLeaveTypes(isActive: true),
      ]);
      defines.value = results[0] as List<LeaveDefine>;
      roles.value = results[1] as List<HrRole>;
      staff.value = results[2] as List<Staff>;
      leaveTypes.value = results[3] as List<LeaveType>;
    } catch (e) { errorMsg.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  void startEdit(LeaveDefine d) {
    editingId.value = d.id; daysCtrl.text = d.days.toString();
    selectedRoleId.value = d.roleId; selectedStaffId.value = d.staffId;
    selectedLeaveTypeId.value = d.leaveTypeId;
  }

  void cancelEdit() {
    editingId.value = null; daysCtrl.text = '0';
    selectedRoleId.value = null; selectedStaffId.value = null; selectedLeaveTypeId.value = null;
  }

  Future<void> save() async {
    if (selectedLeaveTypeId.value == null) { errorMsg.value = 'Leave type is required.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      final data = <String, dynamic>{'days': int.tryParse(daysCtrl.text) ?? 0,
        'leave_type': selectedLeaveTypeId.value,
        if (selectedRoleId.value != null) 'role': selectedRoleId.value,
        if (selectedStaffId.value != null) 'staff': selectedStaffId.value};
      if (editingId.value != null) await _repo.updateLeaveDefine(editingId.value!, data);
      else await _repo.createLeaveDefine(data);
      cancelEdit(); await load();
    } catch (e) { errorMsg.value = e.toString(); }
    finally { isSaving.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteLeaveDefine(id); await load(); }
    catch (e) { errorMsg.value = e.toString(); }
  }
}
