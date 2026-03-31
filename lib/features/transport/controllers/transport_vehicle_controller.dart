import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transport_models.dart';
import '../repositories/transport_repository.dart';

class TransportVehicleController extends GetxController {
  final _repo = TransportRepository();

  final vehicles = <Vehicle>[].obs;
  final drivers = <TransportDriver>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;

  // Form
  final editingId = Rx<int?>(null);
  final vehicleNoCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final madeYearCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final selectedDriverId = Rx<int?>(null);
  final isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    vehicleNoCtrl.dispose();
    vehicleModelCtrl.dispose();
    madeYearCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  List<Vehicle> get filteredVehicles {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return vehicles.toList();
    return vehicles
        .where((v) =>
            v.vehicleNo.toLowerCase().contains(q) ||
            v.vehicleModel.toLowerCase().contains(q))
        .toList();
  }

  String driverName(int? id) {
    if (id == null) return '-';
    final d = drivers.firstWhereOrNull((d) => d.id == id);
    return d?.fullName ?? '-';
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final results = await Future.wait([
        _repo.getVehicles(),
        _repo.getDrivers(),
      ]);
      vehicles.value = results[0] as List<Vehicle>;
      drivers.value = results[1] as List<TransportDriver>;
    } catch (_) {
      errorMsg.value = 'Unable to load vehicles.';
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(Vehicle v) {
    editingId.value = v.id;
    vehicleNoCtrl.text = v.vehicleNo;
    vehicleModelCtrl.text = v.vehicleModel;
    madeYearCtrl.text = v.madeYear?.toString() ?? '';
    noteCtrl.text = v.note;
    selectedDriverId.value = v.driverId;
    isActive.value = v.activeStatus;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    vehicleNoCtrl.clear();
    vehicleModelCtrl.clear();
    madeYearCtrl.clear();
    noteCtrl.clear();
    selectedDriverId.value = null;
    isActive.value = true;
    errorMsg.value = '';
  }

  Future<void> save() async {
    final vehicleNo = vehicleNoCtrl.text.trim();
    final vehicleModel = vehicleModelCtrl.text.trim();
    if (vehicleNo.isEmpty) {
      errorMsg.value = 'Vehicle number is required.';
      return;
    }
    if (vehicleModel.isEmpty) {
      errorMsg.value = 'Vehicle model is required.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final yearText = madeYearCtrl.text.trim();
      final payload = {
        'vehicle_no': vehicleNo,
        'vehicle_model': vehicleModel,
        if (yearText.isNotEmpty && int.tryParse(yearText) != null)
          'made_year': int.parse(yearText),
        'note': noteCtrl.text.trim(),
        if (selectedDriverId.value != null) 'driver': selectedDriverId.value,
        'active_status': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateVehicle(editingId.value!, payload);
      } else {
        await _repo.createVehicle(payload);
      }
      cancelEdit();
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to save vehicle.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteVehicle(id);
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to delete vehicle.';
    }
  }
}
