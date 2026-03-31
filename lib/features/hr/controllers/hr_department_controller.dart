import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrDepartmentController extends GetxController {
  final _repo = HrRepository();
  final departments = <Department>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final editingId = Rx<int?>(null);
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final isActive = true.obs;

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() { nameCtrl.dispose(); descCtrl.dispose(); super.onClose(); }

  List<Department> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return departments.toList();
    return departments.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try { departments.value = await _repo.getDepartments(); }
    catch (e) { errorMsg.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  void startEdit(Department d) {
    editingId.value = d.id; nameCtrl.text = d.name;
    descCtrl.text = d.description; isActive.value = d.isActive;
  }

  void cancelEdit() {
    editingId.value = null; nameCtrl.clear(); descCtrl.clear(); isActive.value = true;
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty) { errorMsg.value = 'Department name is required.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      final data = {'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim(), 'is_active': isActive.value};
      if (editingId.value != null) await _repo.updateDepartment(editingId.value!, data);
      else await _repo.createDepartment(data);
      cancelEdit(); await load();
    } catch (e) { errorMsg.value = e.toString(); }
    finally { isSaving.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteDepartment(id); await load(); }
    catch (e) { errorMsg.value = e.toString(); }
  }
}
