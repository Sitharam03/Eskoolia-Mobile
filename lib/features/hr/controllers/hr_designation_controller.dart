import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrDesignationController extends GetxController {
  final _repo = HrRepository();
  final designations = <Designation>[].obs;
  final departments = <Department>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);
  final nameCtrl = TextEditingController();
  final selectedDepartmentId = Rx<int?>(null);
  final isActive = true.obs;

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() { nameCtrl.dispose(); super.onClose(); }

  List<Designation> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return designations.toList();
    return designations.where((d) => d.name.toLowerCase().contains(q) || d.departmentName.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try {
      final results = await Future.wait([_repo.getDesignations(), _repo.getDepartments(isActive: true)]);
      designations.value = results[0] as List<Designation>;
      departments.value = results[1] as List<Department>;
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isLoading.value = false; }
  }

  void startEdit(Designation d) {
    editingId.value = d.id; nameCtrl.text = d.name;
    selectedDepartmentId.value = d.departmentId; isActive.value = d.isActive;
  }

  void cancelEdit() {
    editingId.value = null; nameCtrl.clear(); selectedDepartmentId.value = null; isActive.value = true;
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) { errorMsg.value = 'Designation name is required.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      final data = <String, dynamic>{'name': nameCtrl.text.trim(), 'is_active': isActive.value,
        if (selectedDepartmentId.value != null) 'department': selectedDepartmentId.value};
      if (editingId.value != null) await _repo.updateDesignation(editingId.value!, data);
      else await _repo.createDesignation(data);
      cancelEdit(); await load();
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isSaving.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteDesignation(id); await load(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
  }
}
