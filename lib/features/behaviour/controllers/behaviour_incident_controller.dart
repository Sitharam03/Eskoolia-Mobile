import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/behaviour_models.dart';
import '../repositories/behaviour_repository.dart';

class BehaviourIncidentController extends GetxController {
  final BehaviourRepository _repo;
  BehaviourIncidentController(this._repo);

  final incidents = <Incident>[].obs;
  final isLoading = true.obs;

  // Form state (inline form)
  final editingId = Rx<int?>(null);
  final titleCtrl = TextEditingController();
  final pointCtrl = TextEditingController(text: '0');
  final descCtrl = TextEditingController();
  final isNegative = false.obs;
  final showForm = false.obs;

  bool get isEditing => editingId.value != null;

  @override
  void onInit() {
    super.onInit();
    loadIncidents();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    pointCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> loadIncidents() async {
    isLoading.value = true;
    try {
      incidents.assignAll(await _repo.getIncidents(
          params: {'page_size': 500}));
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  void startCreate() {
    editingId.value = null;
    titleCtrl.clear();
    pointCtrl.text = '0';
    descCtrl.clear();
    isNegative.value = false;
    showForm.value = true;
  }

  void startEdit(Incident inc) {
    editingId.value = inc.id;
    titleCtrl.text = inc.title;
    final p = inc.point;
    isNegative.value = p < 0;
    pointCtrl.text = p.abs().toString();
    descCtrl.text = inc.description;
    showForm.value = true;
  }

  void cancelForm() {
    showForm.value = false;
    editingId.value = null;
  }

  Future<void> saveIncident() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      _warn('Incident title is required.');
      return;
    }
    final rawPt = int.tryParse(pointCtrl.text.trim()) ?? 0;
    final point = isNegative.value ? -rawPt.abs() : rawPt.abs();

    isLoading.value = true;
    try {
      final data = {
        'title': title,
        'point': point,
        'description': descCtrl.text.trim(),
      };
      if (editingId.value == null) {
        final created = await _repo.createIncident(data);
        incidents.insert(0, created);
        _ok('Incident created.');
      } else {
        final updated = await _repo.updateIncident(editingId.value!, data);
        final idx = incidents.indexWhere((i) => i.id == editingId.value);
        if (idx != -1) incidents[idx] = updated;
        _ok('Incident updated.');
      }
      cancelForm();
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteIncident(int id) async {
    isLoading.value = true;
    try {
      await _repo.deleteIncident(id);
      incidents.removeWhere((i) => i.id == id);
      _ok('Incident deleted.');
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _ok(String msg) => Get.snackbar('Success', msg,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _warn(String msg) => Get.snackbar('Validation', msg,
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _err(Object e) => Get.snackbar('Error', ApiError.extract(e),
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);
}
