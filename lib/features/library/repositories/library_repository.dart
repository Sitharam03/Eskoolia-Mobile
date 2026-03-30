import '../../../core/network/api_client.dart';
import '../models/library_models.dart';

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

class LibraryRepository {
  // ── Categories ───────────────────────────────────────────────────────────────

  Future<List<BookCategory>> getCategories({bool activeOnly = false}) async {
    final path = activeOnly
        ? '/api/v1/library/categories/?is_active=true'
        : '/api/v1/library/categories/';
    final res = await ApiClient.dio.get(path);
    return _parseList(res.data, BookCategory.fromJson);
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/library/categories/', data: data);
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/library/categories/$id/', data: data);
  }

  Future<void> deleteCategory(int id) async {
    await ApiClient.dio.delete('/api/v1/library/categories/$id/');
  }

  // ── Books ─────────────────────────────────────────────────────────────────────

  Future<List<Book>> getBooks() async {
    final res = await ApiClient.dio.get('/api/v1/library/books/');
    return _parseList(res.data, Book.fromJson);
  }

  Future<void> createBook(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/library/books/', data: data);
  }

  Future<void> updateBook(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/library/books/$id/', data: data);
  }

  Future<void> deleteBook(int id) async {
    await ApiClient.dio.delete('/api/v1/library/books/$id/');
  }

  // ── Members ───────────────────────────────────────────────────────────────────

  Future<List<LibraryMember>> getMembers({bool activeOnly = false}) async {
    final path = activeOnly
        ? '/api/v1/library/members/?is_active=true'
        : '/api/v1/library/members/';
    final res = await ApiClient.dio.get(path);
    return _parseList(res.data, LibraryMember.fromJson);
  }

  Future<void> createMember(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/library/members/', data: data);
  }

  Future<void> updateMember(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/library/members/$id/', data: data);
  }

  Future<void> deleteMember(int id) async {
    await ApiClient.dio.delete('/api/v1/library/members/$id/');
  }

  Future<List<LibraryStudent>> getStudents() async {
    final res = await ApiClient.dio
        .get('/api/v1/students/students/?is_active=true');
    return _parseList(res.data, LibraryStudent.fromJson);
  }

  Future<List<LibraryStaff>> getStaff() async {
    final res =
        await ApiClient.dio.get('/api/v1/hr/staff/?status=active');
    return _parseList(res.data, LibraryStaff.fromJson);
  }

  // ── Issues ────────────────────────────────────────────────────────────────────

  Future<List<BookIssue>> getIssues() async {
    final res = await ApiClient.dio.get('/api/v1/library/issues/');
    return _parseList(res.data, BookIssue.fromJson);
  }

  Future<void> issueBook(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/library/issues/', data: data);
  }

  Future<void> markReturned(int id, String returnDate) async {
    await ApiClient.dio.post(
      '/api/v1/library/issues/$id/return/',
      data: {'return_date': returnDate},
    );
  }
}
