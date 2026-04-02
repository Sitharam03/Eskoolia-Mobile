import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrLeaveRequestController extends GetxController {
  final _repo = HrRepository();
  final requests = <LeaveRequest>[].obs;
  final leaveTypes = <LeaveType>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final editingId = Rx<int?>(null);
  final selectedLeaveTypeId = Rx<int?>(null);
  final fromDateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() { fromDateCtrl.dispose(); toDateCtrl.dispose(); reasonCtrl.dispose(); super.onClose(); }

  List<LeaveRequest> get pendingRequests => requests.where((r) => r.status == 'pending').toList();
  List<LeaveRequest> get otherRequests => requests.where((r) => r.status != 'pending').toList();

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try {
      final results = await Future.wait([_repo.getLeaveRequests(), _repo.getLeaveTypes(isActive: true)]);
      requests.value = results[0] as List<LeaveRequest>;
      leaveTypes.value = results[1] as List<LeaveType>;
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isLoading.value = false; }
  }

  void startEdit(LeaveRequest r) {
    editingId.value = r.id; selectedLeaveTypeId.value = r.leaveTypeId;
    fromDateCtrl.text = r.fromDate; toDateCtrl.text = r.toDate; reasonCtrl.text = r.reason;
  }

  void cancelEdit() {
    editingId.value = null; selectedLeaveTypeId.value = null;
    fromDateCtrl.clear(); toDateCtrl.clear(); reasonCtrl.clear();
  }

  Future<void> save() async {
    if (selectedLeaveTypeId.value == null) { errorMsg.value = 'Leave type is required.'; return; }
    if (fromDateCtrl.text.trim().isEmpty || toDateCtrl.text.trim().isEmpty) { errorMsg.value = 'Dates are required.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      final data = {'leave_type': selectedLeaveTypeId.value, 'from_date': fromDateCtrl.text.trim(),
        'to_date': toDateCtrl.text.trim(), 'reason': reasonCtrl.text.trim()};
      if (editingId.value != null) await _repo.updateLeaveRequest(editingId.value!, data);
      else await _repo.createLeaveRequest(data);
      cancelEdit(); await load();
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isSaving.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteLeaveRequest(id); await load(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
  }
}
