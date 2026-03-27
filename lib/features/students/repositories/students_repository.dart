import '../../../core/network/api_client.dart';
import '../models/student_model.dart';
import '../models/student_category_model.dart';
import '../models/student_group_model.dart';
import '../models/guardian_model.dart';
import '../models/multi_class_record_model.dart';

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

class StudentsRepository {
  // ─────────────────────────── CATEGORIES ────────────────────────────────
  Future<List<StudentCategory>> getCategories() async {
    final res = await ApiClient.dio.get('/api/v1/students/categories/');
    return _parseList(res.data, StudentCategory.fromJson);
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/students/categories/', data: data);
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/students/categories/$id/', data: data);
  }

  Future<void> deleteCategory(int id) async {
    await ApiClient.dio.delete('/api/v1/students/categories/$id/');
  }

  // ─────────────────────────── GROUPS ────────────────────────────────────
  Future<List<StudentGroup>> getGroups() async {
    final res = await ApiClient.dio.get('/api/v1/students/groups/');
    return _parseList(res.data, StudentGroup.fromJson);
  }

  Future<void> createGroup(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/students/groups/', data: data);
  }

  Future<void> updateGroup(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/students/groups/$id/', data: data);
  }

  Future<void> deleteGroup(int id) async {
    await ApiClient.dio.delete('/api/v1/students/groups/$id/');
  }

  // ─────────────────────────── STUDENTS ──────────────────────────────────
  Future<List<StudentRow>> getStudents(
      {Map<String, dynamic>? queryParams}) async {
    final res = await ApiClient.dio.get(
      '/api/v1/students/students/',
      queryParameters: queryParams ?? {'page_size': 1000},
    );
    return _parseList(res.data, StudentRow.fromJson);
  }

  Future<StudentRow> createStudent(Map<String, dynamic> data) async {
    final res =
        await ApiClient.dio.post('/api/v1/students/students/', data: data);
    return StudentRow.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StudentRow> updateStudent(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.dio
        .patch('/api/v1/students/students/$id/', data: data);
    return StudentRow.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteStudent(int id) async {
    await ApiClient.dio.delete('/api/v1/students/students/$id/');
  }

  Future<void> promoteStudents(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/students/students/promote/', data: data);
  }

  // ─────────────────────────── GUARDIANS ─────────────────────────────────
  Future<List<Guardian>> getGuardians() async {
    final res = await ApiClient.dio
        .get('/api/v1/students/guardians/', queryParameters: {'page_size': 500});
    return _parseList(res.data, Guardian.fromJson);
  }

  Future<Guardian> createGuardian(Map<String, dynamic> data) async {
    final res =
        await ApiClient.dio.post('/api/v1/students/guardians/', data: data);
    return Guardian.fromJson(res.data as Map<String, dynamic>);
  }

  // ─────────────────────────── MULTI-CLASS RECORDS ───────────────────────
  Future<List<MultiClassRecord>> getMultiClassRecords(int studentId) async {
    final res = await ApiClient.dio.get(
      '/api/v1/students/multi-class-records/',
      queryParameters: {'student': studentId},
    );
    return _parseList(res.data, MultiClassRecord.fromJson);
  }

  Future<void> bulkSaveMultiClassRecords(
      int studentId, List<Map<String, dynamic>> records) async {
    await ApiClient.dio.post(
      '/api/v1/students/multi-class-records/bulk-save/',
      data: {'student': studentId, 'records': records},
    );
  }

  // ─────────────────────────── SUPPORTING DATA ───────────────────────────
  Future<List<Map<String, dynamic>>> getClasses() async {
    final res = await ApiClient.dio.get('/api/v1/core/classes/');
    return _parseList<Map<String, dynamic>>(res.data, (e) => e);
  }

  Future<List<Map<String, dynamic>>> getSections() async {
    final res = await ApiClient.dio.get('/api/v1/core/sections/');
    return _parseList<Map<String, dynamic>>(res.data, (e) => e);
  }

  Future<List<Map<String, dynamic>>> getAcademicYears() async {
    final res = await ApiClient.dio.get('/api/v1/core/academic-years/');
    return _parseList<Map<String, dynamic>>(res.data, (e) => e);
  }
}
