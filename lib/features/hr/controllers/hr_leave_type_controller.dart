import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrLeaveTypeController extends GetxController {
  final _repo = HrRepository();
  final leaveTypes = <LeaveType>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final editingId = Rx<int?>(null);
  final nameCtrl = TextEditingController();
  final maxDaysCtrl = TextEditingController(text: '0');
  final isPaid = false.obs;
  final isActive = true.obs;

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() { nameCtrl.dispose(); maxDaysCtrl.dispose(); super.onClose(); }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try { leaveTypes.value = await _repo.getLeaveTypes(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isLoading.value = false; }
  }

  void startEdit(LeaveType lt) {
    editingId.value = lt.id; nameCtrl.text = lt.name;
    maxDaysCtrl.text = lt.maxDaysPerYear.toString();
    isPaid.value = lt.isPaid; isActive.value = lt.isActive;
  }

  void cancelEdit() {
    editingId.value = null; nameCtrl.clear(); maxDaysCtrl.text = '0';
    isPaid.value = false; isActive.value = true;
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) { errorMsg.value = 'Leave type name is required.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      final data = {'name': nameCtrl.text.trim(), 'max_days_per_year': int.tryParse(maxDaysCtrl.text) ?? 0,
        'is_paid': isPaid.value, 'is_active': isActive.value};
      if (editingId.value != null) await _repo.updateLeaveType(editingId.value!, data);
      else await _repo.createLeaveType(data);
      cancelEdit(); await load();
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isSaving.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteLeaveType(id); await load(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
  }
}
