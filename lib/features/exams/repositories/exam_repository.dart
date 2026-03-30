import '../../../core/network/api_client.dart';
import '../models/exam_models.dart';

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

class ExamRepository {
  // ─────────────────────────── EXAM TYPE ─────────────────────────────────────

  Future<List<ExamType>> getExamTypes() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-type/');
    final data = res.data;
    if (data is Map && data['exams_types'] is List) {
      return _parseList(data['exams_types'], ExamType.fromJson);
    }
    return _parseList(data, ExamType.fromJson);
  }

  Future<ExamType> getExamTypeById(int id) async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-type/edit/$id/');
    return ExamType.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> createExamType(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-type/store/', data: data);
  }

  Future<void> updateExamType(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-type/update/', data: data);
  }

  Future<void> deleteExamType(int id) async {
    await ApiClient.dio.get('/api/v1/exams/exam-type/delete/$id/');
  }

  // ─────────────────────────── EXAM SETUP ────────────────────────────────────

  Future<Map<String, dynamic>> getExamSetupIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-setup/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchExamSetup({
    required int classId,
    required int sectionId,
    required int subjectId,
    required int examTermId,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/v1/exams/exam-setup/search/',
      queryParameters: {
        'class': classId,
        'section': sectionId,
        'subject': subjectId,
        'exam_term_id': examTermId,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> saveExamSetup(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-setup/store/', data: data);
  }

  // ─────────────────────────── EXAM SCHEDULE ─────────────────────────────────

  Future<Map<String, dynamic>> getExamScheduleIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-schedule/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchExamSchedule(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-schedule/search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> saveExamSchedule(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-schedule/store/', data: data);
  }

  // ─────────────────────────── MARKS REGISTER ────────────────────────────────

  Future<Map<String, dynamic>> getMarksIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-marks/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchMarksCreate(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-marks/create-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> saveMarks(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-marks/store/', data: data);
  }

  Future<Map<String, dynamic>> searchMarksReport(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-marks/report-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  // ─────────────────────────── ADMIT CARD ────────────────────────────────────

  Future<Map<String, dynamic>> getAdmitCardIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-plan/admit-card/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAdmitCardSetting() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-plan/admit-card/setting/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchAdmitCard(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-plan/admit-card/search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> generateAdmitCard(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-plan/admit-card/generate/', data: data);
  }

  // ─────────────────────────── SEAT PLAN ─────────────────────────────────────

  Future<Map<String, dynamic>> getSeatPlanIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-plan/seat-plan/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSeatPlanSetting() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-plan/seat-plan/setting/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchSeatPlan(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-plan/seat-plan/search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> generateSeatPlan(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-plan/seat-plan/generate/', data: data);
  }

  // ─────────────────────────── EXAM ATTENDANCE ───────────────────────────────

  Future<Map<String, dynamic>> getAttendanceIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-attendance/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchAttendanceCreate(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-attendance/create-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> saveAttendance(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-attendance/store/', data: data);
  }

  Future<Map<String, dynamic>> searchAttendanceReport(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-attendance/report-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  // ─────────────────────────── RESULT PUBLISH ────────────────────────────────

  Future<Map<String, dynamic>> getResultPublishIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-result-publish/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchResultPublish(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-result-publish/search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<void> publishResult(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/exam-result-publish/store/', data: data);
  }

  // ─────────────────────────── EXAM REPORTS ──────────────────────────────────

  Future<Map<String, dynamic>> getExamReportIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/exam-report/index/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchMeritReport(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-report/merit-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchStudentReport(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-report/student-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  // ─────────────────────────── SCHEDULE REPORT ───────────────────────────────

  Future<Map<String, dynamic>> searchScheduleReport(Map<String, dynamic> payload) async {
    final res = await ApiClient.dio
        .post('/api/v1/exams/exam-schedule/report-search/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  // ─────────────────────────── ONLINE EXAM ───────────────────────────────────

  Future<Map<String, dynamic>> getOnlineExamIndex() async {
    final res = await ApiClient.dio.get('/api/v1/exams/online-exam/');
    return res.data as Map<String, dynamic>;
  }

  Future<void> createOnlineExam(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/online-exam/store/', data: data);
  }

  Future<void> updateOnlineExam(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/exams/online-exam/update/', data: data);
  }

  Future<void> deleteOnlineExam(int id) async {
    await ApiClient.dio.post('/api/v1/exams/online-exam/delete/', data: {'id': id});
  }

  Future<void> publishOnlineExam(int id) async {
    await ApiClient.dio.get('/api/v1/exams/online-exam/publish/$id/');
  }

  Future<void> cancelPublishOnlineExam(int id) async {
    await ApiClient.dio.get('/api/v1/exams/online-exam/publish-cancel/$id/');
  }

  Future<Map<String, dynamic>> getOnlineExamMarks(int id) async {
    final res = await ApiClient.dio.get('/api/v1/exams/online-exam/marks-register/$id/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOnlineExamResult(int id) async {
    final res = await ApiClient.dio.get('/api/v1/exams/online-exam/result/$id/');
    return res.data as Map<String, dynamic>;
  }
}
