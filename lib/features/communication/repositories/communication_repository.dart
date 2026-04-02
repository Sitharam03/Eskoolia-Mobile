import '../../../core/network/api_client.dart';
import '../models/communication_models.dart';

class CommunicationRepository {
  // ── Generic list parser ───────────────────────────────────────────────────
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

  // ── Notice Board ──────────────────────────────────────────────────────────

  Future<List<NoticeBoard>> getNotices({Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
      '/api/v1/utilities/communication/notice-boards/',
      queryParameters: params,
    );
    return _list(r.data, NoticeBoard.fromJson);
  }

  Future<NoticeBoard> createNotice(Map<String, dynamic> data) async {
    final r = await ApiClient.dio.post(
      '/api/v1/utilities/communication/notice-boards/',
      data: data,
    );
    return NoticeBoard.fromJson(r.data as Map<String, dynamic>);
  }

  Future<NoticeBoard> updateNotice(int id, Map<String, dynamic> data) async {
    final r = await ApiClient.dio.patch(
      '/api/v1/utilities/communication/notice-boards/$id/',
      data: data,
    );
    return NoticeBoard.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteNotice(int id) async {
    await ApiClient.dio.delete(
      '/api/v1/utilities/communication/notice-boards/$id/',
    );
  }

  // ── Email / SMS Logs ──────────────────────────────────────────────────────

  Future<List<EmailSmsLog>> getEmailLogs({Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
      '/api/v1/utilities/communication/email-logs/',
      queryParameters: params,
    );
    return _list(r.data, EmailSmsLog.fromJson);
  }

  Future<EmailSmsLog> sendEmail(Map<String, dynamic> data) async {
    final r = await ApiClient.dio.post(
      '/api/v1/utilities/communication/email-logs/',
      data: data,
    );
    return EmailSmsLog.fromJson(r.data as Map<String, dynamic>);
  }

  // ── Holiday Calendar ──────────────────────────────────────────────────────

  Future<List<HolidayCalendar>> getHolidays({Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
      '/api/v1/utilities/communication/holiday-calendars/',
      queryParameters: params,
    );
    return _list(r.data, HolidayCalendar.fromJson);
  }

  Future<HolidayCalendar> createHoliday(Map<String, dynamic> data) async {
    final r = await ApiClient.dio.post(
      '/api/v1/utilities/communication/holiday-calendars/',
      data: data,
    );
    return HolidayCalendar.fromJson(r.data as Map<String, dynamic>);
  }

  Future<HolidayCalendar> updateHoliday(int id, Map<String, dynamic> data) async {
    final r = await ApiClient.dio.patch(
      '/api/v1/utilities/communication/holiday-calendars/$id/',
      data: data,
    );
    return HolidayCalendar.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteHoliday(int id) async {
    await ApiClient.dio.delete(
      '/api/v1/utilities/communication/holiday-calendars/$id/',
    );
  }

  // ── Support: Roles & Users ────────────────────────────────────────────────

  /// Backend returns {"roles": [...], "classes": [...], "sections": [...]} in ONE call.
  /// We cache classes/sections from this response too.
  List<CommClassRef> _cachedClasses = [];
  List<CommSectionRef> _cachedSections = [];

  Future<List<CommRole>> getRoles() async {
    final r = await ApiClient.dio.get(
      '/api/v1/access-control/login-access-control/',
    );
    final data = r.data;
    if (data is Map<String, dynamic>) {
      // Extract roles
      final rolesList = (data['roles'] as List<dynamic>?) ?? [];
      // Also cache classes and sections from the same response
      final classesList = (data['classes'] as List<dynamic>?) ?? [];
      final sectionsList = (data['sections'] as List<dynamic>?) ?? [];
      _cachedClasses = classesList
          .map((c) => CommClassRef.fromJson(c as Map<String, dynamic>))
          .toList();
      _cachedSections = sectionsList
          .map((s) => CommSectionRef.fromJson(s as Map<String, dynamic>))
          .toList();
      return rolesList
          .map((r) => CommRole.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    return _list(data, CommRole.fromJson);
  }

  Future<List<CommUser>> getUsers({Map<String, dynamic>? params}) async {
    final r = await ApiClient.dio.get(
      '/api/v1/access-control/login-access-control/users/',
      queryParameters: params,
    );
    // Backend returns {"users": [...]} or {"results": [...]}
    final data = r.data;
    if (data is Map<String, dynamic>) {
      final usersList = (data['users'] as List<dynamic>?) ??
          (data['results'] as List<dynamic>?) ??
          [];
      return usersList
          .map((u) => CommUser.fromJson(u as Map<String, dynamic>))
          .toList();
    }
    return _list(data, CommUser.fromJson);
  }

  // ── Support: Classes & Sections ───────────────────────────────────────────

  Future<List<CommClassRef>> getClasses() async {
    // Return cached if available (from getRoles call)
    if (_cachedClasses.isNotEmpty) return _cachedClasses;
    final r = await ApiClient.dio.get(
      '/api/v1/core/classes/',
      queryParameters: {'page_size': 200},
    );
    return _list(r.data, CommClassRef.fromJson);
  }

  Future<List<CommSectionRef>> getSections({int? classId}) async {
    // Use cached sections from getRoles call, filter by class
    if (_cachedSections.isNotEmpty) {
      if (classId != null) {
        return _cachedSections.where((s) => s.classId == classId).toList();
      }
      return _cachedSections;
    }
    final params = <String, dynamic>{'page_size': 500};
    if (classId != null) params['school_class'] = classId;
    final r = await ApiClient.dio.get(
      '/api/v1/core/sections/',
      queryParameters: params,
    );
    return _list(r.data, CommSectionRef.fromJson);
  }
}
