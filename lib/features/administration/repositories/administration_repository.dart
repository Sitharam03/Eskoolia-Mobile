import '../../../core/network/api_client.dart';
import '../models/visitor_book_model.dart';
import '../models/complaint_model.dart';
import '../models/phone_call_log_model.dart';
import '../models/postal_model.dart';
import '../models/admin_setup_model.dart';
import '../models/admission_query_model.dart';
import '../models/id_card_model.dart';
import '../models/certificate_model.dart';
import '../models/admin_recipient_model.dart';
import 'package:dio/dio.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List)
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  if (data is Map && data['results'] is List) {
    return (data['results'] as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

class AdministrationRepository {
  // ───────── VISITOR BOOK ─────────
  Future<List<VisitorBookItem>> getVisitors() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/visitors/');
    return _parseList(res.data, VisitorBookItem.fromJson);
  }

  Future<void> createVisitor(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/visitors/', data: data);
  }

  Future<void> updateVisitor(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/admissions/visitors/$id/', data: data);
  }

  Future<void> deleteVisitor(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/visitors/$id/');
  }

  // ───────── COMPLAINTS ─────────
  Future<List<ComplaintItem>> getComplaints() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/complaints/');
    return _parseList(res.data, ComplaintItem.fromJson);
  }

  Future<void> createComplaint(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/complaints/', data: data);
  }

  Future<void> updateComplaint(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/admissions/complaints/$id/', data: data);
  }

  Future<void> deleteComplaint(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/complaints/$id/');
  }

  // ───────── PHONE CALL LOG ─────────
  Future<List<PhoneCallLogItem>> getPhoneCallLogs() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/phone-call-logs/');
    return _parseList(res.data, PhoneCallLogItem.fromJson);
  }

  Future<void> createPhoneCallLog(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/phone-call-logs/', data: data);
  }

  Future<void> updatePhoneCallLog(int id, Map<String, dynamic> data) async {
    await ApiClient.dio
        .patch('/api/v1/admissions/phone-call-logs/$id/', data: data);
  }

  Future<void> deletePhoneCallLog(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/phone-call-logs/$id/');
  }

  // ───────── POSTAL DISPATCH ─────────
  Future<List<PostalItem>> getPostalDispatch() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/postal-dispatch/');
    return _parseList(res.data, PostalItem.fromJson);
  }

  Future<void> createPostalDispatch(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/postal-dispatch/', data: data);
  }

  Future<void> updatePostalDispatch(int id, Map<String, dynamic> data) async {
    await ApiClient.dio
        .patch('/api/v1/admissions/postal-dispatch/$id/', data: data);
  }

  Future<void> deletePostalDispatch(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/postal-dispatch/$id/');
  }

  // ───────── POSTAL RECEIVE ─────────
  Future<List<PostalItem>> getPostalReceive() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/postal-receive/');
    return _parseList(res.data, PostalItem.fromJson);
  }

  Future<void> createPostalReceive(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/postal-receive/', data: data);
  }

  Future<void> updatePostalReceive(int id, Map<String, dynamic> data) async {
    await ApiClient.dio
        .patch('/api/v1/admissions/postal-receive/$id/', data: data);
  }

  Future<void> deletePostalReceive(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/postal-receive/$id/');
  }

  // ───────── ADMIN SETUP ─────────
  Future<List<AdminSetupItem>> getAdminSetups() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/admin-setups/');
    return _parseList(res.data, AdminSetupItem.fromJson);
  }

  Future<void> createAdminSetup(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/admin-setups/', data: data);
  }

  Future<void> updateAdminSetup(int id, Map<String, dynamic> data) async {
    await ApiClient.dio
        .patch('/api/v1/admissions/admin-setups/$id/', data: data);
  }

  Future<void> deleteAdminSetup(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/admin-setups/$id/');
  }

  // ───────── ADMISSION QUERY ─────────
  Future<List<AdmissionQueryItem>> getAdmissionQueries() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/inquiries/');
    return _parseList(res.data, AdmissionQueryItem.fromJson);
  }

  Future<void> createAdmissionQuery(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/admissions/inquiries/', data: data);
  }

  Future<void> updateAdmissionQuery(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/admissions/inquiries/$id/', data: data);
  }

  Future<void> deleteAdmissionQuery(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/inquiries/$id/');
  }

  // ───────── ID CARD TEMPLATES ─────────
  Future<List<IdCardTemplate>> getIdCardTemplates() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/id-card-templates/?page_size=100');
    return _parseList(res.data, IdCardTemplate.fromJson);
  }

  Future<void> createIdCardTemplate(FormData data) async {
    await ApiClient.dio.post('/api/v1/admissions/id-card-templates/', data: data);
  }

  Future<void> updateIdCardTemplate(int id, FormData data) async {
    await ApiClient.dio.patch('/api/v1/admissions/id-card-templates/$id/', data: data);
  }

  Future<void> deleteIdCardTemplate(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/id-card-templates/$id/');
  }

  // ───────── CERTIFICATE TEMPLATES ─────────
  Future<List<CertificateTemplate>> getCertificateTemplates() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/certificate-templates/?page_size=100');
    return _parseList(res.data, CertificateTemplate.fromJson);
  }

  Future<void> createCertificateTemplate(FormData data) async {
    await ApiClient.dio.post('/api/v1/admissions/certificate-templates/', data: data);
  }

  Future<void> updateCertificateTemplate(int id, FormData data) async {
    await ApiClient.dio.patch('/api/v1/admissions/certificate-templates/$id/', data: data);
  }

  Future<void> deleteCertificateTemplate(int id) async {
    await ApiClient.dio.delete('/api/v1/admissions/certificate-templates/$id/');
  }

  // ───────── GENERATION & SETUP ─────────
  Future<GenerateSetupData> getGenerateSetupData() async {
    final res = await ApiClient.dio.get('/api/v1/admissions/certificate-templates/generate-setup/');
    return GenerateSetupData.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<AdminRecipient>> getCertificateRecipients(String roleId, String? classId, String? sectionId) async {
    final q = {'role': roleId};
    if (classId != null && classId.isNotEmpty) q['class'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) q['section'] = sectionId;
    final res = await ApiClient.dio.get('/api/v1/admissions/certificate-templates/recipients/', queryParameters: q);
    final data = res.data;
    if (data is Map && data['recipients'] is List) {
      return (data['recipients'] as List).map((e) => AdminRecipient.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<AdminRecipient>> getAllStudents() async {
    final res = await ApiClient.dio.get('/api/v1/students/students/?page_size=1000');
    if (res.data is Map && res.data['results'] is List) {
      return (res.data['results'] as List).map((e) => AdminRecipient.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
