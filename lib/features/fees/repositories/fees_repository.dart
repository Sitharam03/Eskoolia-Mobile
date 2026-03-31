import '../../../core/network/api_client.dart';
import '../models/fees_assignment_model.dart';
import '../models/fees_group_model.dart';
import '../models/fees_payment_model.dart';
import '../models/fees_type_model.dart';

class FeesRepository {
  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    List raw;
    if (data is Map) {
      raw = (data['results'] ?? data['data'] ?? []) as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = [];
    }
    return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Fees Groups ──────────────────────────────────────────────────────────

  Future<List<FeesGroup>> getGroups({Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/fees/groups/', queryParameters: params);
    return _parseList(resp.data, FeesGroup.fromJson);
  }

  Future<FeesGroup> createGroup(Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.post('/api/v1/fees/groups/', data: data);
    return FeesGroup.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<FeesGroup> updateGroup(int id, Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.patch('/api/v1/fees/groups/$id/', data: data);
    return FeesGroup.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteGroup(int id) async {
    await ApiClient.dio.delete('/api/v1/fees/groups/$id/');
  }

  // ─── Fees Types ───────────────────────────────────────────────────────────

  Future<List<FeesType>> getTypes({Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/fees/types/', queryParameters: params);
    return _parseList(resp.data, FeesType.fromJson);
  }

  Future<FeesType> createType(Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.post('/api/v1/fees/types/', data: data);
    return FeesType.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<FeesType> updateType(int id, Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.patch('/api/v1/fees/types/$id/', data: data);
    return FeesType.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteType(int id) async {
    await ApiClient.dio.delete('/api/v1/fees/types/$id/');
  }

  // ─── Fees Assignments ─────────────────────────────────────────────────────

  Future<List<FeesAssignment>> getAssignments(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/fees/assignments/', queryParameters: params);
    return _parseList(resp.data, FeesAssignment.fromJson);
  }

  Future<FeesAssignment> createAssignment(Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.post('/api/v1/fees/assignments/', data: data);
    return FeesAssignment.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<FeesAssignment> updateAssignment(
      int id, Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .patch('/api/v1/fees/assignments/$id/', data: data);
    return FeesAssignment.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteAssignment(int id) async {
    await ApiClient.dio.delete('/api/v1/fees/assignments/$id/');
  }

  Future<FeesSummary> getSummary({Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/fees/assignments/summary/',
        queryParameters: params);
    return FeesSummary.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<FeesAssignment>> getOverdue(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/fees/assignments/overdue/',
        queryParameters: params);
    return _parseList(resp.data, FeesAssignment.fromJson);
  }

  Future<Map<String, dynamic>> carryForward(
      Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .post('/api/v1/fees/assignments/carry-forward/', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ─── Fees Payments ────────────────────────────────────────────────────────

  Future<List<FeesPayment>> getPayments(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/fees/payments/', queryParameters: params);
    return _parseList(resp.data, FeesPayment.fromJson);
  }

  Future<FeesPayment> createPayment(Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.post('/api/v1/fees/payments/', data: data);
    return FeesPayment.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deletePayment(int id) async {
    await ApiClient.dio.delete('/api/v1/fees/payments/$id/');
  }

  Future<FeesReceipt> getReceipt(int id) async {
    final resp =
        await ApiClient.dio.get('/api/v1/fees/payments/$id/receipt/');
    return FeesReceipt.fromJson(resp.data as Map<String, dynamic>);
  }

  // ─── Support Data ─────────────────────────────────────────────────────────

  Future<List<AcademicYearRef>> getAcademicYears() async {
    final resp = await ApiClient.dio.get('/api/v1/core/academic-years/',
        queryParameters: {'page_size': 100});
    return _parseList(resp.data, AcademicYearRef.fromJson);
  }

  Future<List<StudentRef>> getStudents() async {
    final resp = await ApiClient.dio.get('/api/v1/students/students/',
        queryParameters: {'page_size': 2000});
    return _parseList(resp.data, StudentRef.fromJson);
  }
}
