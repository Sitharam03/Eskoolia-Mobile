import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/transport_models.dart';
import '../repositories/transport_repository.dart';

class TransportRouteController extends GetxController {
  final _repo = TransportRepository();

  final routes = <TransportRoute>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;

  // Form
  final editingId = Rx<int?>(null);
  final titleCtrl = TextEditingController();
  final fareCtrl = TextEditingController();
  final isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    fareCtrl.dispose();
    super.onClose();
  }

  List<TransportRoute> get filteredRoutes {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return routes.toList();
    return routes.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      routes.value = await _repo.getRoutes();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to load routes.');
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(TransportRoute r) {
    editingId.value = r.id;
    titleCtrl.text = r.title;
    fareCtrl.text = r.fare;
    isActive.value = r.activeStatus;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    titleCtrl.clear();
    fareCtrl.clear();
    isActive.value = true;
    errorMsg.value = '';
  }

  Future<void> save() async {
    final title = titleCtrl.text.trim();
    final fare = fareCtrl.text.trim();
    if (title.isEmpty) {
      errorMsg.value = 'Route title is required.';
      return;
    }
    if (fare.isEmpty || double.tryParse(fare) == null) {
      errorMsg.value = 'Valid fare amount is required.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'title': title,
        'fare': double.parse(fare),
        'active_status': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateRoute(editingId.value!, payload);
      } else {
        await _repo.createRoute(payload);
      }
      cancelEdit();
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to save route.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteRoute(id);
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to delete route.');
    }
  }
}
