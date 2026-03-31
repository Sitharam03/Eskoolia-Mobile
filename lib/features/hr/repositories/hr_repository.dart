import '../../../core/network/api_client.dart';
import '../models/hr_models.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
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

class HrRepository {
  // ── Departments ───────────────────────────────────────────────────────────

  Future<List<Department>> getDepartments({bool? isActive}) async {
    final q = isActive != null ? '?is_active=$isActive' : '';
    final res = await ApiClient.dio.get('/api/v1/hr/departments/$q');
    return _parseList(res.data, Department.fromJson);
  }

  Future<void> createDepartment(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/departments/', data: data);
  }

  Future<void> updateDepartment(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/hr/departments/$id/', data: data);
  }

  Future<void> deleteDepartment(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/departments/$id/');
  }

  // ── Designations ──────────────────────────────────────────────────────────

  Future<List<Designation>> getDesignations({bool? isActive}) async {
    final q = isActive != null ? '?is_active=$isActive' : '';
    final res = await ApiClient.dio.get('/api/v1/hr/designations/$q');
    return _parseList(res.data, Designation.fromJson);
  }

  Future<void> createDesignation(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/designations/', data: data);
  }

  Future<void> updateDesignation(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/hr/designations/$id/', data: data);
  }

  Future<void> deleteDesignation(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/designations/$id/');
  }

  // ── Roles ─────────────────────────────────────────────────────────────────

  Future<List<HrRole>> getRoles() async {
    final res = await ApiClient.dio.get('/api/v1/access-control/roles/');
    return _parseList(res.data, HrRole.fromJson);
  }

  // ── Staff ─────────────────────────────────────────────────────────────────

  Future<List<Staff>> getStaff({String? status}) async {
    final q = status != null ? '?status=$status' : '';
    final res = await ApiClient.dio.get('/api/v1/hr/staff/$q');
    return _parseList(res.data, Staff.fromJson);
  }

  Future<Staff> getStaffById(int id) async {
    final res = await ApiClient.dio.get('/api/v1/hr/staff/$id/');
    return Staff.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> getNextStaffNo() async {
    final res = await ApiClient.dio.get('/api/v1/hr/staff/next-staff-no/');
    return res.data['staff_no']?.toString() ?? '';
  }

  Future<void> createStaff(dynamic data) async {
    await ApiClient.dio.post('/api/v1/hr/staff/', data: data);
  }

  Future<void> updateStaff(int id, dynamic data) async {
    await ApiClient.dio.patch('/api/v1/hr/staff/$id/', data: data);
  }

  Future<void> deleteStaff(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/staff/$id/');
  }

  // ── Leave Types ───────────────────────────────────────────────────────────

  Future<List<LeaveType>> getLeaveTypes({bool? isActive}) async {
    final q = isActive != null ? '?is_active=$isActive' : '';
    final res = await ApiClient.dio.get('/api/v1/hr/leave-types/$q');
    return _parseList(res.data, LeaveType.fromJson);
  }

  Future<void> createLeaveType(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/leave-types/', data: data);
  }

  Future<void> updateLeaveType(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/hr/leave-types/$id/', data: data);
  }

  Future<void> deleteLeaveType(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/leave-types/$id/');
  }

  // ── Leave Defines ─────────────────────────────────────────────────────────

  Future<List<LeaveDefine>> getLeaveDefines() async {
    final res = await ApiClient.dio.get('/api/v1/hr/leave-defines/');
    return _parseList(res.data, LeaveDefine.fromJson);
  }

  Future<void> createLeaveDefine(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/leave-defines/', data: data);
  }

  Future<void> updateLeaveDefine(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/hr/leave-defines/$id/', data: data);
  }

  Future<void> deleteLeaveDefine(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/leave-defines/$id/');
  }

  // ── Leave Requests ────────────────────────────────────────────────────────

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final res = await ApiClient.dio.get('/api/v1/hr/leave-requests/');
    return _parseList(res.data, LeaveRequest.fromJson);
  }

  Future<void> createLeaveRequest(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/leave-requests/', data: data);
  }

  Future<void> updateLeaveRequest(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/hr/leave-requests/$id/', data: data);
  }

  Future<void> deleteLeaveRequest(int id) async {
    await ApiClient.dio.delete('/api/v1/hr/leave-requests/$id/');
  }

  // ── Staff Attendance ──────────────────────────────────────────────────────

  Future<List<StaffAttendance>> getAttendanceByDate(String date) async {
    final res = await ApiClient.dio
        .get('/api/v1/hr/staff-attendance/?attendance_date=$date');
    return _parseList(res.data, StaffAttendance.fromJson);
  }

  Future<Map<String, dynamic>> getAttendanceReport(String date) async {
    final res = await ApiClient.dio
        .get('/api/v1/hr/staff-attendance/report/?attendance_date=$date');
    return res.data as Map<String, dynamic>;
  }

  Future<void> bulkStoreAttendance(List<Map<String, dynamic>> rows) async {
    await ApiClient.dio.post('/api/v1/hr/staff-attendance/bulk-store/',
        data: {'rows': rows});
  }

  // ── Payroll ───────────────────────────────────────────────────────────────

  Future<List<PayrollRecord>> getPayroll({String? status}) async {
    final q = status != null && status.isNotEmpty ? '?status=$status' : '';
    final res = await ApiClient.dio.get('/api/v1/hr/payroll/$q');
    return _parseList(res.data, PayrollRecord.fromJson);
  }

  Future<Map<String, dynamic>> getPayrollSummary() async {
    final res = await ApiClient.dio.get('/api/v1/hr/payroll/summary/');
    return res.data as Map<String, dynamic>;
  }

  Future<void> createPayroll(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/hr/payroll/', data: data);
  }

  Future<void> markPayrollPaid(int id) async {
    await ApiClient.dio.post('/api/v1/hr/payroll/$id/mark-paid/');
  }
}
