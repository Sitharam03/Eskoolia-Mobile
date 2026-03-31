import 'package:get/get.dart';
import '../models/transport_models.dart';
import '../repositories/transport_repository.dart';

class TransportAssignController extends GetxController {
  final _repo = TransportRepository();

  final assignments = <AssignVehicle>[].obs;
  final vehicles = <Vehicle>[].obs;
  final routes = <TransportRoute>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  // Form
  final editingId = Rx<int?>(null);
  final selectedVehicleId = Rx<int?>(null);
  final selectedRouteId = Rx<int?>(null);
  final isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final results = await Future.wait([
        _repo.getAssignments(),
        _repo.getVehicles(),
        _repo.getRoutes(),
      ]);
      assignments.value = results[0] as List<AssignVehicle>;
      vehicles.value = results[1] as List<Vehicle>;
      routes.value = results[2] as List<TransportRoute>;
    } catch (_) {
      errorMsg.value = 'Unable to load assignments.';
    } finally {
      isLoading.value = false;
    }
  }

  String vehicleLabel(int? id) {
    if (id == null) return '-';
    final v = vehicles.firstWhereOrNull((v) => v.id == id);
    return v?.vehicleNo ?? '-';
  }

  String routeLabel(int? id) {
    if (id == null) return '-';
    final r = routes.firstWhereOrNull((r) => r.id == id);
    return r?.title ?? '-';
  }

  void startEdit(AssignVehicle a) {
    editingId.value = a.id;
    selectedVehicleId.value = a.vehicleId;
    selectedRouteId.value = a.routeId;
    isActive.value = a.activeStatus;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    selectedVehicleId.value = null;
    selectedRouteId.value = null;
    isActive.value = true;
    errorMsg.value = '';
  }

  Future<void> save() async {
    if (selectedVehicleId.value == null) {
      errorMsg.value = 'Please select a vehicle.';
      return;
    }
    if (selectedRouteId.value == null) {
      errorMsg.value = 'Please select a route.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'vehicle': selectedVehicleId.value,
        'route': selectedRouteId.value,
        'active_status': isActive.value,
      };
      if (editingId.value != null) {
        await _repo.updateAssignment(editingId.value!, payload);
      } else {
        await _repo.createAssignment(payload);
      }
      cancelEdit();
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to save assignment.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteAssignment(id);
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to delete assignment.';
    }
  }
}
