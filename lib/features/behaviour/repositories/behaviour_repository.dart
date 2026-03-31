import '../../../core/network/api_client.dart';
import '../models/behaviour_models.dart';

class BehaviourRepository {
  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) from) {
    List raw;
    if (data is Map) {
      raw = (data['results'] ?? data['data'] ?? []) as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = [];
    }
    return raw.map((e) => from(e as Map<String, dynamic>)).toList();
  }

  // ── Incidents ────────────────────────────────────────────────────────────────

  Future<List<Incident>> getIncidents({Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get('/api/v1/behaviour/incidents/',
        queryParameters: params);
    return _list(r.data, Incident.fromJson);
  }

  Future<Incident> createIncident(Map<String, dynamic> data) async {
    final r = await ApiClient.dio.post('/api/v1/behaviour/incidents/', data: data);
    return Incident.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Incident> updateIncident(int id, Map<String, dynamic> data) async {
    final r = await ApiClient.dio.patch('/api/v1/behaviour/incidents/$id/', data: data);
    return Incident.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteIncident(int id) async {
    await ApiClient.dio.delete('/api/v1/behaviour/incidents/$id/');
  }

  // ── Assignments ──────────────────────────────────────────────────────────────

  Future<List<AssignedIncident>> getAssignments(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get('/api/v1/behaviour/assignments/',
        queryParameters: params);
    return _list(r.data, AssignedIncident.fromJson);
  }

  Future<AssignedIncident> createAssignment(Map<String, dynamic> data) async {
    final r = await ApiClient.dio
        .post('/api/v1/behaviour/assignments/', data: data);
    return AssignedIncident.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteAssignment(int id) async {
    await ApiClient.dio.delete('/api/v1/behaviour/assignments/$id/');
  }

  Future<Map<String, dynamic>> assignBulk(Map<String, dynamic> data) async {
    final r = await ApiClient.dio
        .post('/api/v1/behaviour/assignments/assign-bulk/', data: data);
    return r.data as Map<String, dynamic>;
  }

  // ── Comments ─────────────────────────────────────────────────────────────────

  Future<AssignedIncidentComment> createComment(Map<String, dynamic> data) async {
    final r =
        await ApiClient.dio.post('/api/v1/behaviour/comments/', data: data);
    return AssignedIncidentComment.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteComment(int id) async {
    await ApiClient.dio.delete('/api/v1/behaviour/comments/$id/');
  }

  // ── Reports ──────────────────────────────────────────────────────────────────

  Future<List<StudentIncidentReportRow>> getStudentIncidentReport(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
        '/api/v1/behaviour/assignments/student-incident-report/',
        queryParameters: params);
    return _list(r.data, StudentIncidentReportRow.fromJson);
  }

  Future<List<StudentSummaryRow>> getStudentsSummary(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
        '/api/v1/behaviour/assignments/students-summary/',
        queryParameters: params);
    return _list(r.data, StudentSummaryRow.fromJson);
  }

  Future<List<StudentRankRow>> getStudentRankReport(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
        '/api/v1/behaviour/assignments/student-rank-report/',
        queryParameters: params);
    return _list(r.data, StudentRankRow.fromJson);
  }

  Future<List<ClassSectionRankRow>> getClassSectionRankReport(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
        '/api/v1/behaviour/assignments/class-section-rank-report/',
        queryParameters: params);
    return _list(r.data, ClassSectionRankRow.fromJson);
  }

  Future<List<IncidentWiseRow>> getIncidentWiseReport(
      {Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
        '/api/v1/behaviour/assignments/incident-wise-report/',
        queryParameters: params);
    return _list(r.data, IncidentWiseRow.fromJson);
  }

  // ── Settings ─────────────────────────────────────────────────────────────────

  Future<BehaviourSetting> getSettings() async {
    final r = await ApiClient.dio.get('/api/v1/behaviour/settings/');
    return BehaviourSetting.fromJson(r.data as Map<String, dynamic>);
  }

  Future<BehaviourSetting> updateSettings(Map<String, dynamic> data) async {
    final r =
        await ApiClient.dio.patch('/api/v1/behaviour/settings/', data: data);
    return BehaviourSetting.fromJson(r.data as Map<String, dynamic>);
  }

  // ── Support data ─────────────────────────────────────────────────────────────

  Future<List<BAcademicYearRef>> getAcademicYears() async {
    final r = await ApiClient.dio.get('/api/v1/core/academic-years/',
        queryParameters: {'page_size': 100});
    return _list(r.data, BAcademicYearRef.fromJson);
  }

  Future<List<BClassRef>> getClasses() async {
    final r = await ApiClient.dio.get('/api/v1/core/classes/',
        queryParameters: {'page_size': 200});
    return _list(r.data, BClassRef.fromJson);
  }

  Future<List<BSectionRef>> getSections({int? classId}) async {
    final params = <String, dynamic>{'page_size': 500};
    if (classId != null) params['school_class'] = classId;
    final r = await ApiClient.dio.get('/api/v1/core/sections/',
        queryParameters: params);
    return _list(r.data, BSectionRef.fromJson);
  }

  Future<List<BStudentRef>> getStudents({Map<String, dynamic>? params}) async {
    final p = <String, dynamic>{'page_size': 2000, ...?params};
    final r = await ApiClient.dio.get('/api/v1/students/students/',
        queryParameters: p);
    return _list(r.data, BStudentRef.fromJson);
  }
}
