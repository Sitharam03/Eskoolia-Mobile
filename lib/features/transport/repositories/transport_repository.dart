import '../../../core/network/api_client.dart';
import '../models/transport_models.dart';

List<T> _parseList<T>(
    dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map && data['results'] is List) {
    return (data['results'] as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

class TransportRepository {
  // ── Transport Routes ────────────────────────────────────────────────────────

  Future<List<TransportRoute>> getRoutes() async {
    final res = await ApiClient.dio.get('/api/v1/core/transport-routes/');
    return _parseList(res.data, TransportRoute.fromJson);
  }

  Future<void> createRoute(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/transport-routes/', data: data);
  }

  Future<void> updateRoute(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/transport-routes/$id/', data: data);
  }

  Future<void> deleteRoute(int id) async {
    await ApiClient.dio.delete('/api/v1/core/transport-routes/$id/');
  }

  // ── Vehicles ────────────────────────────────────────────────────────────────

  Future<List<Vehicle>> getVehicles() async {
    final res = await ApiClient.dio.get('/api/v1/core/vehicles/');
    return _parseList(res.data, Vehicle.fromJson);
  }

  Future<void> createVehicle(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/vehicles/', data: data);
  }

  Future<void> updateVehicle(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/vehicles/$id/', data: data);
  }

  Future<void> deleteVehicle(int id) async {
    await ApiClient.dio.delete('/api/v1/core/vehicles/$id/');
  }

  // ── Assign Vehicles ─────────────────────────────────────────────────────────

  Future<List<AssignVehicle>> getAssignments() async {
    final res = await ApiClient.dio.get('/api/v1/core/assign-vehicles/');
    return _parseList(res.data, AssignVehicle.fromJson);
  }

  Future<void> createAssignment(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/assign-vehicles/', data: data);
  }

  Future<void> updateAssignment(int id, Map<String, dynamic> data) async {
    await ApiClient.dio
        .patch('/api/v1/core/assign-vehicles/$id/', data: data);
  }

  Future<void> deleteAssignment(int id) async {
    await ApiClient.dio.delete('/api/v1/core/assign-vehicles/$id/');
  }

  // ── Drivers (Staff) ─────────────────────────────────────────────────────────

  Future<List<TransportDriver>> getDrivers() async {
    final res = await ApiClient.dio
        .get('/api/v1/hr/staff/?drivers_only=true&page_size=500');
    return _parseList(res.data, TransportDriver.fromJson);
  }

  // ── Students ────────────────────────────────────────────────────────────────

  Future<List<StudentTransport>> getStudents() async {
    final res = await ApiClient.dio.get('/api/v1/students/students/');
    return _parseList(res.data, StudentTransport.fromJson);
  }
}
