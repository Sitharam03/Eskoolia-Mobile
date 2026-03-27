import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/visitor_book_model.dart';
import '../models/complaint_model.dart';
import '../models/phone_call_log_model.dart';
import '../models/postal_model.dart';
import '../models/admin_setup_model.dart';
import '../models/admission_query_model.dart';
import '../models/id_card_model.dart';
import '../models/certificate_model.dart';
import '../models/admin_recipient_model.dart';
import '../repositories/administration_repository.dart';
import 'package:dio/dio.dart' as dio;

class AdministrationController extends GetxController {
  final AdministrationRepository repository;
  AdministrationController({required this.repository});

  // ── Loading / Saving ──
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  // ── Editing ID per section ──
  final RxnInt editingId = RxnInt();

  // ── Visitor Book ──
  final RxList<VisitorBookItem> visitors = <VisitorBookItem>[].obs;
  final purposeCtrl = TextEditingController();
  final visitorNameCtrl = TextEditingController();
  final visitorPhoneCtrl = TextEditingController();
  final visitorIdCtrl = TextEditingController();
  final noOfPersonCtrl = TextEditingController(text: '1');
  final visitorDateCtrl = TextEditingController();
  final inTimeCtrl = TextEditingController();
  final outTimeCtrl = TextEditingController();

  // ── Complaint ──
  final RxList<ComplaintItem> complaints = <ComplaintItem>[].obs;
  final complaintByCtrl = TextEditingController();
  final complaintTypeCtrl = TextEditingController();
  final complaintSourceCtrl = TextEditingController();
  final complaintPhoneCtrl = TextEditingController();
  final complaintDateCtrl = TextEditingController();
  final actionTakenCtrl = TextEditingController();
  final assignedCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // ── Phone Call Log ──
  final RxList<PhoneCallLogItem> phoneCalls = <PhoneCallLogItem>[].obs;
  final callNameCtrl = TextEditingController();
  final callPhoneCtrl = TextEditingController();
  final callDateCtrl = TextEditingController();
  final followUpDateCtrl = TextEditingController();
  final callDurationCtrl = TextEditingController();
  final callDescCtrl = TextEditingController();
  final RxString callType = 'I'.obs;

  // ── Postal Dispatch ──
  final RxList<PostalItem> postalDispatch = <PostalItem>[].obs;

  // ── Postal Receive ──
  final RxList<PostalItem> postalReceive = <PostalItem>[].obs;

  // Shared postal fields
  final toTitleCtrl = TextEditingController();
  final refNoCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final fromTitleCtrl = TextEditingController();
  final postalDateCtrl = TextEditingController();

  // ── Admin Setup ──
  final RxList<AdminSetupItem> adminSetups = <AdminSetupItem>[].obs;
  final setupNameCtrl = TextEditingController();
  final setupDescCtrl = TextEditingController();
  final RxString setupType = '1'.obs;

  // ── Admission Query ──
  final RxList<AdmissionQueryItem> admissionQueries =
      <AdmissionQueryItem>[].obs;
  final queryFullNameCtrl = TextEditingController();
  final queryPhoneCtrl = TextEditingController();
  final queryEmailCtrl = TextEditingController();
  final queryAddressCtrl = TextEditingController();
  final queryClassCtrl = TextEditingController();
  final queryAssignedCtrl = TextEditingController();
  final queryDateCtrl = TextEditingController();
  final queryNoteCtrl = TextEditingController();
  final queryDescCtrl = TextEditingController();
  final RxString queryStatus = 'new'.obs;
  final RxnInt selectedSourceId = RxnInt();
  final RxnInt selectedReferenceId = RxnInt();
  final RxInt activeStatusValue = 1.obs; // 1 = Active, 0 = Inactive

  // ── ID Card Templates ──
  final RxList<IdCardTemplate> idCardTemplates = <IdCardTemplate>[].obs;
  final RxnString idCardLogoPath = RxnString();
  final RxnString idCardBackgroundPath = RxnString();
  final RxnString idCardProfilePath = RxnString();
  final RxnString idCardSignaturePath = RxnString();
  final RxList<int> idCardRoleIds = <int>[].obs;
  
  // ── Certificate Templates ──
  final RxList<CertificateTemplate> certificateTemplates = <CertificateTemplate>[].obs;
  final RxnString certBackgroundPath = RxnString();

  // ── Generate Setup & Recipients ──
  final RxList<RoleOption> generateRoles = <RoleOption>[].obs;
  final RxList<ClassOption> generateClasses = <ClassOption>[].obs;
  final RxList<SectionOption> generateSections = <SectionOption>[].obs;
  final RxList<AdminRecipient> generateRecipients = <AdminRecipient>[].obs;
  final RxList<int> selectedRecipientIds = <int>[].obs;

  @override
  void onClose() {
    for (final c in [
      purposeCtrl,
      visitorNameCtrl,
      visitorPhoneCtrl,
      visitorIdCtrl,
      noOfPersonCtrl,
      visitorDateCtrl,
      inTimeCtrl,
      outTimeCtrl,
      complaintByCtrl,
      complaintTypeCtrl,
      complaintSourceCtrl,
      complaintPhoneCtrl,
      complaintDateCtrl,
      actionTakenCtrl,
      assignedCtrl,
      descriptionCtrl,
      callNameCtrl,
      callPhoneCtrl,
      callDateCtrl,
      followUpDateCtrl,
      callDurationCtrl,
      callDescCtrl,
      toTitleCtrl,
      refNoCtrl,
      addressCtrl,
      noteCtrl,
      fromTitleCtrl,
      postalDateCtrl,
      setupNameCtrl,
      setupDescCtrl,
      queryFullNameCtrl,
      queryPhoneCtrl,
      queryEmailCtrl,
      queryAddressCtrl,
      queryClassCtrl,
      queryAssignedCtrl,
      queryDateCtrl,
      queryNoteCtrl,
      queryDescCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  // ── Helpers ──
  void _success(String msg) => Get.snackbar('Success', msg,
      backgroundColor: const Color(0xFF059669),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _error(String msg) => Get.snackbar('Error', msg,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void resetEdit() => editingId.value = null;

  // ──────────────────────────────────────────────────────────────────────────
  // VISITOR BOOK
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadVisitors() async {
    isLoading.value = true;
    try {
      visitors.assignAll(await repository.getVisitors());
    } catch (_) {
      _error('Unable to load visitor records.');
    } finally {
      isLoading.value = false;
    }
  }

  List<VisitorBookItem> get filteredVisitors {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return visitors;
    return visitors
        .where((v) => '${v.name} ${v.purpose} ${v.phone} ${v.visitorId}'
            .toLowerCase()
            .contains(q))
        .toList();
  }

  void startEditVisitor(VisitorBookItem v) {
    editingId.value = v.id;
    purposeCtrl.text = v.purpose;
    visitorNameCtrl.text = v.name;
    visitorPhoneCtrl.text = v.phone;
    visitorIdCtrl.text = v.visitorId;
    noOfPersonCtrl.text = v.noOfPerson.toString();
    visitorDateCtrl.text = v.date;
    inTimeCtrl.text = v.inTime;
    outTimeCtrl.text = v.outTime;
  }

  void resetVisitorForm() {
    editingId.value = null;
    purposeCtrl.clear();
    visitorNameCtrl.clear();
    visitorPhoneCtrl.clear();
    visitorIdCtrl.clear();
    noOfPersonCtrl.text = '1';
    visitorDateCtrl.clear();
    inTimeCtrl.clear();
    outTimeCtrl.clear();
  }

  Future<void> saveVisitor() async {
    if (purposeCtrl.text.trim().isEmpty ||
        visitorNameCtrl.text.trim().isEmpty ||
        visitorIdCtrl.text.trim().isEmpty ||
        visitorDateCtrl.text.isEmpty ||
        inTimeCtrl.text.trim().isEmpty ||
        outTimeCtrl.text.trim().isEmpty) {
      _error('Purpose, name, ID, date, in-time and out-time are required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'purpose': purposeCtrl.text.trim(),
        'name': visitorNameCtrl.text.trim(),
        'phone': visitorPhoneCtrl.text.trim(),
        'visitor_id': visitorIdCtrl.text.trim(),
        'no_of_person': int.tryParse(noOfPersonCtrl.text) ?? 1,
        'date': visitorDateCtrl.text,
        'in_time': inTimeCtrl.text.trim(),
        'out_time': outTimeCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await repository.updateVisitor(editingId.value!, data);
        _success('Visitor updated successfully.');
      } else {
        await repository.createVisitor(data);
        _success('Visitor added successfully.');
      }
      resetVisitorForm();
      await loadVisitors();
    } catch (_) {
      _error('Unable to save visitor.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteVisitor(int id) async {
    try {
      await repository.deleteVisitor(id);
      visitors.removeWhere((v) => v.id == id);
      _success('Visitor deleted.');
    } catch (_) {
      _error('Unable to delete visitor.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COMPLAINTS
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadComplaints() async {
    isLoading.value = true;
    try {
      complaints.assignAll(await repository.getComplaints());
    } catch (_) {
      _error('Unable to load complaints.');
    } finally {
      isLoading.value = false;
    }
  }

  List<ComplaintItem> get filteredComplaints {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return complaints;
    return complaints
        .where((c) =>
            '${c.complaintBy} ${c.complaintType} ${c.complaintSource} ${c.phone}'
                .toLowerCase()
                .contains(q))
        .toList();
  }

  void startEditComplaint(ComplaintItem c) {
    editingId.value = c.id;
    complaintByCtrl.text = c.complaintBy;
    complaintTypeCtrl.text = c.complaintType;
    complaintSourceCtrl.text = c.complaintSource;
    complaintPhoneCtrl.text = c.phone;
    complaintDateCtrl.text = c.date;
    actionTakenCtrl.text = c.actionTaken;
    assignedCtrl.text = c.assigned;
    descriptionCtrl.text = c.description;
  }

  void resetComplaintForm() {
    editingId.value = null;
    complaintByCtrl.clear();
    complaintTypeCtrl.clear();
    complaintSourceCtrl.clear();
    complaintPhoneCtrl.clear();
    complaintDateCtrl.clear();
    actionTakenCtrl.clear();
    assignedCtrl.clear();
    descriptionCtrl.clear();
  }

  Future<void> saveComplaint() async {
    if (complaintByCtrl.text.trim().isEmpty ||
        complaintTypeCtrl.text.trim().isEmpty ||
        complaintSourceCtrl.text.trim().isEmpty) {
      _error('Complaint by, type and source are required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'complaint_by': complaintByCtrl.text.trim(),
        'complaint_type': complaintTypeCtrl.text.trim(),
        'complaint_source': complaintSourceCtrl.text.trim(),
        'phone': complaintPhoneCtrl.text.trim(),
        'date': complaintDateCtrl.text.isEmpty ? null : complaintDateCtrl.text,
        'action_taken': actionTakenCtrl.text.trim(),
        'assigned': assignedCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await repository.updateComplaint(editingId.value!, data);
        _success('Complaint updated successfully.');
      } else {
        await repository.createComplaint(data);
        _success('Complaint added successfully.');
      }
      resetComplaintForm();
      await loadComplaints();
    } catch (_) {
      _error('Unable to save complaint.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteComplaint(int id) async {
    try {
      await repository.deleteComplaint(id);
      complaints.removeWhere((c) => c.id == id);
      _success('Complaint deleted.');
    } catch (_) {
      _error('Unable to delete complaint.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PHONE CALL LOG
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPhoneCalls() async {
    isLoading.value = true;
    try {
      phoneCalls.assignAll(await repository.getPhoneCallLogs());
    } catch (_) {
      _error('Unable to load phone call logs.');
    } finally {
      isLoading.value = false;
    }
  }

  List<PhoneCallLogItem> get filteredPhoneCalls {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return phoneCalls;
    return phoneCalls
        .where((p) => '${p.name} ${p.phone} ${p.description} ${p.callTypeLabel}'
            .toLowerCase()
            .contains(q))
        .toList();
  }

  void startEditPhoneCall(PhoneCallLogItem p) {
    editingId.value = p.id;
    callNameCtrl.text = p.name;
    callPhoneCtrl.text = p.phone;
    callDateCtrl.text = p.date;
    followUpDateCtrl.text = p.nextFollowUpDate;
    callDurationCtrl.text = p.callDuration;
    callDescCtrl.text = p.description;
    callType.value = p.callType;
  }

  void resetPhoneCallForm() {
    editingId.value = null;
    callNameCtrl.clear();
    callPhoneCtrl.clear();
    callDateCtrl.clear();
    followUpDateCtrl.clear();
    callDurationCtrl.clear();
    callDescCtrl.clear();
    callType.value = 'I';
  }

  Future<void> savePhoneCall() async {
    if (callPhoneCtrl.text.trim().isEmpty) {
      _error('Phone is required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'name': callNameCtrl.text.trim(),
        'phone': callPhoneCtrl.text.trim(),
        'date': callDateCtrl.text.isEmpty ? null : callDateCtrl.text,
        'next_follow_up_date':
            followUpDateCtrl.text.isEmpty ? null : followUpDateCtrl.text,
        'call_duration': callDurationCtrl.text.trim(),
        'description': callDescCtrl.text.trim(),
        'call_type': callType.value,
      };
      if (editingId.value != null) {
        await repository.updatePhoneCallLog(editingId.value!, data);
        _success('Phone call updated.');
      } else {
        await repository.createPhoneCallLog(data);
        _success('Phone call saved.');
      }
      resetPhoneCallForm();
      await loadPhoneCalls();
    } catch (_) {
      _error('Unable to save phone call.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePhoneCall(int id) async {
    try {
      await repository.deletePhoneCallLog(id);
      phoneCalls.removeWhere((p) => p.id == id);
      _success('Phone call deleted.');
    } catch (_) {
      _error('Unable to delete phone call.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // POSTAL DISPATCH
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPostalDispatch() async {
    isLoading.value = true;
    try {
      postalDispatch.assignAll(await repository.getPostalDispatch());
    } catch (_) {
      _error('Unable to load postal dispatch records.');
    } finally {
      isLoading.value = false;
    }
  }

  List<PostalItem> get filteredPostalDispatch {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return postalDispatch;
    return postalDispatch
        .where((p) =>
            '${p.toTitle} ${p.fromTitle} ${p.referenceNo} ${p.address}'
                .toLowerCase()
                .contains(q))
        .toList();
  }

  void startEditPostal(PostalItem p) {
    editingId.value = p.id;
    toTitleCtrl.text = p.toTitle;
    refNoCtrl.text = p.referenceNo;
    addressCtrl.text = p.address;
    noteCtrl.text = p.note;
    fromTitleCtrl.text = p.fromTitle;
    postalDateCtrl.text = p.date;
  }

  void resetPostalForm() {
    editingId.value = null;
    toTitleCtrl.clear();
    refNoCtrl.clear();
    addressCtrl.clear();
    noteCtrl.clear();
    fromTitleCtrl.clear();
    postalDateCtrl.clear();
  }

  Future<void> savePostalDispatch() async {
    if (toTitleCtrl.text.trim().isEmpty ||
        refNoCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        fromTitleCtrl.text.trim().isEmpty) {
      _error('To title, reference no, address and from title are required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'to_title': toTitleCtrl.text.trim(),
        'reference_no': refNoCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'note': noteCtrl.text.trim(),
        'from_title': fromTitleCtrl.text.trim(),
        'date': postalDateCtrl.text.isEmpty ? null : postalDateCtrl.text,
      };
      if (editingId.value != null) {
        await repository.updatePostalDispatch(editingId.value!, data);
        _success('Postal dispatch updated.');
      } else {
        await repository.createPostalDispatch(data);
        _success('Postal dispatch saved.');
      }
      resetPostalForm();
      await loadPostalDispatch();
    } catch (_) {
      _error('Unable to save postal dispatch.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePostalDispatch(int id) async {
    try {
      await repository.deletePostalDispatch(id);
      postalDispatch.removeWhere((p) => p.id == id);
      _success('Postal dispatch deleted.');
    } catch (_) {
      _error('Unable to delete postal dispatch.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // POSTAL RECEIVE
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPostalReceive() async {
    isLoading.value = true;
    try {
      postalReceive.assignAll(await repository.getPostalReceive());
    } catch (_) {
      _error('Unable to load postal receive records.');
    } finally {
      isLoading.value = false;
    }
  }

  List<PostalItem> get filteredPostalReceive {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return postalReceive;
    return postalReceive
        .where((p) =>
            '${p.toTitle} ${p.fromTitle} ${p.referenceNo} ${p.address}'
                .toLowerCase()
                .contains(q))
        .toList();
  }

  Future<void> savePostalReceive() async {
    if (toTitleCtrl.text.trim().isEmpty ||
        refNoCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        fromTitleCtrl.text.trim().isEmpty) {
      _error('To title, reference no, address and from title are required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'to_title': toTitleCtrl.text.trim(),
        'reference_no': refNoCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'note': noteCtrl.text.trim(),
        'from_title': fromTitleCtrl.text.trim(),
        'date': postalDateCtrl.text.isEmpty ? null : postalDateCtrl.text,
      };
      if (editingId.value != null) {
        await repository.updatePostalReceive(editingId.value!, data);
        _success('Postal receive updated.');
      } else {
        await repository.createPostalReceive(data);
        _success('Postal receive saved.');
      }
      resetPostalForm();
      await loadPostalReceive();
    } catch (_) {
      _error('Unable to save postal receive.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePostalReceive(int id) async {
    try {
      await repository.deletePostalReceive(id);
      postalReceive.removeWhere((p) => p.id == id);
      _success('Postal receive deleted.');
    } catch (_) {
      _error('Unable to delete postal receive.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ADMIN SETUP
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadAdminSetups() async {
    isLoading.value = true;
    try {
      adminSetups.assignAll(await repository.getAdminSetups());
    } catch (_) {
      _error('Unable to load admin setups.');
    } finally {
      isLoading.value = false;
    }
  }

  List<AdminSetupItem> setupsForType(String type) =>
      adminSetups.where((s) => s.type == type).toList();

  void startEditSetup(AdminSetupItem s) {
    editingId.value = s.id;
    setupType.value = s.type;
    setupNameCtrl.text = s.name;
    setupDescCtrl.text = s.description;
  }

  void resetSetupForm() {
    editingId.value = null;
    setupType.value = '1';
    setupNameCtrl.clear();
    setupDescCtrl.clear();
  }

  Future<void> saveAdminSetup() async {
    if (setupNameCtrl.text.trim().isEmpty) {
      _error('Name is required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'type': setupType.value,
        'name': setupNameCtrl.text.trim(),
        'description': setupDescCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await repository.updateAdminSetup(editingId.value!, data);
        _success('Admin setup updated.');
      } else {
        await repository.createAdminSetup(data);
        _success('Admin setup saved.');
      }
      resetSetupForm();
      await loadAdminSetups();
    } catch (_) {
      _error('Unable to save admin setup.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAdminSetup(int id) async {
    try {
      await repository.deleteAdminSetup(id);
      adminSetups.removeWhere((s) => s.id == id);
      _success('Admin setup deleted.');
    } catch (_) {
      _error('Unable to delete admin setup.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ADMISSION QUERY
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadAdmissionQueries() async {
    isLoading.value = true;
    try {
      admissionQueries.assignAll(await repository.getAdmissionQueries());
    } catch (e) {
      _error('Unable to load admission queries.');
    } finally {
      isLoading.value = false;
    }
  }

  List<AdmissionQueryItem> get filteredAdmissionQueries {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return admissionQueries;
    return admissionQueries
        .where((a) =>
            '${a.fullName} ${a.phone} ${a.email} ${a.className} ${a.statusLabel}'
                .toLowerCase()
                .contains(q))
        .toList();
  }

  void startEditQuery(AdmissionQueryItem a) {
    editingId.value = a.id;
    queryFullNameCtrl.text = a.fullName;
    queryPhoneCtrl.text = a.phone;
    queryEmailCtrl.text = a.email;
    queryAddressCtrl.text = a.address;
    queryClassCtrl.text = a.className;
    queryAssignedCtrl.text = a.assigned;
    queryDateCtrl.text = a.queryDate;
    queryNoteCtrl.text = a.note;
    queryDescCtrl.text = a.description;
    queryStatus.value = a.status.isEmpty ? 'new' : a.status;
    selectedSourceId.value = a.sourceId;
    selectedReferenceId.value = a.referenceId;
    activeStatusValue.value = a.activeStatus;
  }

  void resetQueryForm() {
    editingId.value = null;
    queryFullNameCtrl.clear();
    queryPhoneCtrl.clear();
    queryEmailCtrl.clear();
    queryAddressCtrl.clear();
    queryClassCtrl.clear();
    queryAssignedCtrl.clear();
    queryDateCtrl.clear();
    queryNoteCtrl.clear();
    queryDescCtrl.clear();
    queryStatus.value = 'new';
    selectedSourceId.value = null;
    selectedReferenceId.value = null;
    activeStatusValue.value = 1;
  }

  Future<void> saveAdmissionQuery() async {
    if (queryFullNameCtrl.text.trim().isEmpty ||
        queryPhoneCtrl.text.trim().isEmpty) {
      _error('Name and phone are required.');
      return;
    }
    isSaving.value = true;
    try {
      final data = {
        'full_name': queryFullNameCtrl.text.trim(),
        'phone': queryPhoneCtrl.text.trim(),
        'email': queryEmailCtrl.text.trim(),
        'address': queryAddressCtrl.text.trim(),
        'class_name': queryClassCtrl.text.trim(),
        'assigned': queryAssignedCtrl.text.trim(),
        'query_date': queryDateCtrl.text.isEmpty ? null : queryDateCtrl.text,
        'note': queryNoteCtrl.text.trim(),
        'description': queryDescCtrl.text.trim(),
        'status': queryStatus.value,
        'active_status': activeStatusValue.value,
        if (selectedSourceId.value != null) 'source': selectedSourceId.value,
        if (selectedReferenceId.value != null)
          'reference': selectedReferenceId.value,
      };
      if (editingId.value != null) {
        await repository.updateAdmissionQuery(editingId.value!, data);
        _success('Admission query updated.');
      } else {
        await repository.createAdmissionQuery(data);
        _success('Admission query added.');
      }
      resetQueryForm();
      await loadAdmissionQueries();
    } catch (_) {
      _error('Unable to save admission query.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAdmissionQuery(int id) async {
    try {
      await repository.deleteAdmissionQuery(id);
      admissionQueries.removeWhere((a) => a.id == id);
      _success('Admission query deleted.');
    } catch (_) {
      _error('Unable to delete admission query.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ID CARD & CERTIFICATE TEMPLATES
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadIdCardTemplates() async {
    isLoading.value = true;
    try {
      idCardTemplates.assignAll(await repository.getIdCardTemplates());
    } catch (_) {
      _error('Unable to load ID card templates.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveIdCardTemplate(dio.FormData data, {int? id}) async {
    isSaving.value = true;
    try {
      if (id != null) {
        await repository.updateIdCardTemplate(id, data);
        _success('ID Card updated.');
      } else {
        await repository.createIdCardTemplate(data);
        _success('ID Card saved.');
      }
      resetEdit();
      await loadIdCardTemplates();
    } catch (_) {
      _error('Unable to save ID card template.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteIdCardTemplate(int id) async {
    try {
      await repository.deleteIdCardTemplate(id);
      idCardTemplates.removeWhere((i) => i.id == id);
      _success('ID Card template deleted.');
    } catch (_) {
      _error('Unable to delete ID card template.');
    }
  }

  Future<void> loadCertificateTemplates() async {
    isLoading.value = true;
    try {
      certificateTemplates.assignAll(await repository.getCertificateTemplates());
    } catch (_) {
      _error('Unable to load certificate templates.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCertificateTemplate(dio.FormData data, {int? id}) async {
    isSaving.value = true;
    try {
      if (id != null) {
        await repository.updateCertificateTemplate(id, data);
        _success('Certificate updated.');
      } else {
        await repository.createCertificateTemplate(data);
        _success('Certificate saved.');
      }
      resetEdit();
      await loadCertificateTemplates();
    } catch (_) {
      _error('Unable to save certificate template.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCertificateTemplate(int id) async {
    try {
      await repository.deleteCertificateTemplate(id);
      certificateTemplates.removeWhere((c) => c.id == id);
      _success('Certificate template deleted.');
    } catch (_) {
      _error('Unable to delete certificate template.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GENERATE RECPIENTS
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> loadGenerateSetup() async {
    isLoading.value = true;
    try {
      // we only want to fetch once if not already fetched
      if (generateRoles.isEmpty) {
        final setup = await repository.getGenerateSetupData();
        generateRoles.assignAll(setup.roles);
        generateClasses.assignAll(setup.classes);
        generateSections.assignAll(setup.sections);
      }
    } catch (_) {
      _error('Unable to load roles/classes/sections.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchCertificateRecipients(String roleId, String? classId, String? sectionId) async {
    isLoading.value = true;
    try {
      selectedRecipientIds.clear();
      generateRecipients.assignAll(await repository.getCertificateRecipients(roleId, classId, sectionId));
    } catch (_) {
      _error('Unable to load recipients.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchIdCardStudents(String? classId, String? sectionId) async {
    isLoading.value = true;
    try {
      selectedRecipientIds.clear();
      final all = await repository.getAllStudents();
      final filtered = all.where((s) {
        if (classId != null && classId.isNotEmpty) {
           if (s.classId?.toString() != classId) return false;
        }
        if (sectionId != null && sectionId.isNotEmpty) {
           if (s.sectionId?.toString() != sectionId) return false;
        }
        return true;
      }).toList();
      generateRecipients.assignAll(filtered);
    } catch (_) {
      _error('Unable to load students.');
    } finally {
      isLoading.value = false;
    }
  }
}
