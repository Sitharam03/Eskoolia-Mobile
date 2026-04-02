import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/transport_models.dart';
import '../repositories/transport_repository.dart';

class TransportStudentReportController extends GetxController {
  final _repo = TransportRepository();

  final students = <StudentTransport>[].obs;
  final routes = <TransportRoute>[].obs;
  final vehicles = <Vehicle>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  // Filters
  final routeFilter = Rx<int?>(null);
  final vehicleFilter = Rx<int?>(null);
  final activeOnly = true.obs;

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
        _repo.getStudents(),
        _repo.getRoutes(),
        _repo.getVehicles(),
      ]);
      students.value = results[0] as List<StudentTransport>;
      routes.value = results[1] as List<TransportRoute>;
      vehicles.value = results[2] as List<Vehicle>;
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to load report data.');
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentTransport> get filteredStudents {
    return students.where((s) {
      if (activeOnly.value && !s.isActive) return false;
      if (routeFilter.value != null) {
        final r = routes.firstWhereOrNull((r) => r.id == routeFilter.value);
        if (r != null && s.transportRouteTitle != r.title) return false;
      }
      if (vehicleFilter.value != null) {
        final v = vehicles.firstWhereOrNull((v) => v.id == vehicleFilter.value);
        if (v != null && s.vehicleNo != v.vehicleNo) return false;
      }
      return true;
    }).toList();
  }

  void clearFilters() {
    routeFilter.value = null;
    vehicleFilter.value = null;
    activeOnly.value = true;
  }
}
