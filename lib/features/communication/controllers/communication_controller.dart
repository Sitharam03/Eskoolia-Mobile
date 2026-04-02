import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_error.dart';
import '../models/communication_models.dart';
import '../repositories/communication_repository.dart';

class CommunicationController extends GetxController {
  final CommunicationRepository _repo;
  CommunicationController(this._repo);

  // ── Tab state ─────────────────────────────────────────────────────────────
  final activeTab = 0.obs;

  // ── Notice Board ──────────────────────────────────────────────────────────
  final notices = <NoticeBoard>[].obs;
  final noticeLoading = true.obs;
  final noticeSaving = false.obs;
  final showNoticeForm = false.obs;
  final noticeEditingId = Rx<int?>(null);
  final noticeTitleCtrl = TextEditingController();
  final noticeMessageCtrl = TextEditingController();
  final selectedRoles = <int>[].obs;
  final noticeDate = Rx<DateTime?>(null);
  final publishDate = Rx<DateTime?>(null);
  final isPublished = false.obs;

  bool get isNoticeEditing => noticeEditingId.value != null;

  // ── Send Email ────────────────────────────────────────────────────────────
  final emailTitleCtrl = TextEditingController();
  final emailDescCtrl = TextEditingController();
  final sendTo = 'group'.obs; // 'group' | 'individual' | 'class'
  final selectedRoleId = Rx<int?>(null);
  final selectedUsers = <int>[].obs;
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final targetStudentsOrParents = 'students'.obs;
  final emailSending = false.obs;

  // ── Shared dropdowns ──────────────────────────────────────────────────────
  final roles = <CommRole>[].obs;
  final users = <CommUser>[].obs;
  final classes = <CommClassRef>[].obs;
  final sections = <CommSectionRef>[].obs;
  final usersLoading = false.obs;

  // ── Email Logs ────────────────────────────────────────────────────────────
  final emailLogs = <EmailSmsLog>[].obs;
  final logsLoading = true.obs;

  // ── Holiday Calendar ──────────────────────────────────────────────────────
  final holidays = <HolidayCalendar>[].obs;
  final holidayLoading = true.obs;
  final holidaySaving = false.obs;
  final showHolidayForm = false.obs;
  final holidayEditingId = Rx<int?>(null);
  final holidayTitleCtrl = TextEditingController();
  final holidayStartDate = Rx<DateTime?>(null);
  final holidayEndDate = Rx<DateTime?>(null);
  final holidayIsActive = true.obs;
  final holidaySearch = ''.obs;

  bool get isHolidayEditing => holidayEditingId.value != null;

  List<HolidayCalendar> get filteredHolidays {
    final q = holidaySearch.value.toLowerCase();
    if (q.isEmpty) return holidays;
    return holidays.where((h) => h.title.toLowerCase().contains(q)).toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
  }

  @override
  void onClose() {
    noticeTitleCtrl.dispose();
    noticeMessageCtrl.dispose();
    emailTitleCtrl.dispose();
    emailDescCtrl.dispose();
    holidayTitleCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadInitial() async {
    await Future.wait([
      loadNotices(),
      loadRoles(),
      loadClasses(),
      loadEmailLogs(),
      loadHolidays(),
    ]);
  }

  // ── Notice Board CRUD ─────────────────────────────────────────────────────

  Future<void> loadNotices() async {
    noticeLoading.value = true;
    try {
      notices.assignAll(await _repo.getNotices(params: {'page_size': 500}));
    } catch (e) {
      _err(e);
    } finally {
      noticeLoading.value = false;
    }
  }

  void startNoticeCreate() {
    noticeEditingId.value = null;
    noticeTitleCtrl.clear();
    noticeMessageCtrl.clear();
    selectedRoles.clear();
    noticeDate.value = DateTime.now();
    publishDate.value = DateTime.now();
    isPublished.value = false;
    showNoticeForm.value = true;
  }

  void startNoticeEdit(NoticeBoard n) {
    noticeEditingId.value = n.id;
    noticeTitleCtrl.text = n.title;
    noticeMessageCtrl.text = n.message;
    selectedRoles.assignAll(n.informTo);
    noticeDate.value = _tryParse(n.noticeDate);
    publishDate.value = _tryParse(n.publishDate);
    isPublished.value = n.isPublished;
    showNoticeForm.value = true;
  }

  void cancelNoticeForm() {
    showNoticeForm.value = false;
    noticeEditingId.value = null;
  }

  Future<void> saveNotice() async {
    final title = noticeTitleCtrl.text.trim();
    if (title.isEmpty) {
      _warn('Notice title is required.');
      return;
    }
    if (noticeMessageCtrl.text.trim().isEmpty) {
      _warn('Notice message is required.');
      return;
    }
    if (selectedRoles.isEmpty) {
      _warn('Please select at least one role to inform.');
      return;
    }

    noticeSaving.value = true;
    try {
      final data = {
        'title': title,
        'message': noticeMessageCtrl.text.trim(),
        'inform_to': selectedRoles.toList(),
        'notice_date': _fmt(noticeDate.value),
        'publish_date': _fmt(publishDate.value),
        'is_published': isPublished.value,
      };

      if (noticeEditingId.value == null) {
        final created = await _repo.createNotice(data);
        notices.insert(0, created);
        _ok('Notice created.');
      } else {
        final updated = await _repo.updateNotice(noticeEditingId.value!, data);
        final idx = notices.indexWhere((n) => n.id == noticeEditingId.value);
        if (idx != -1) notices[idx] = updated;
        _ok('Notice updated.');
      }
      cancelNoticeForm();
    } catch (e) {
      _err(e);
    } finally {
      noticeSaving.value = false;
    }
  }

  Future<void> deleteNotice(int id) async {
    noticeLoading.value = true;
    try {
      await _repo.deleteNotice(id);
      notices.removeWhere((n) => n.id == id);
      _ok('Notice deleted.');
    } catch (e) {
      _err(e);
    } finally {
      noticeLoading.value = false;
    }
  }

  // ── Send Email ────────────────────────────────────────────────────────────

  Future<void> loadRoles() async {
    try {
      // getRoles() also caches classes/sections from the same backend response
      roles.assignAll(await _repo.getRoles());
      // Load classes from cache after roles are loaded
      final cachedClasses = await _repo.getClasses();
      if (cachedClasses.isNotEmpty) classes.assignAll(cachedClasses);
    } catch (e) {
      _err(e);
    }
  }

  Future<void> loadClasses() async {
    try {
      classes.assignAll(await _repo.getClasses());
    } catch (e) {
      _err(e);
    }
  }

  Future<void> loadSectionsForClass(int classId) async {
    selectedSectionId.value = null;
    try {
      sections.assignAll(await _repo.getSections(classId: classId));
    } catch (e) {
      _err(e);
    }
  }

  Future<void> loadUsersForRole(int roleId) async {
    usersLoading.value = true;
    try {
      users.assignAll(
        await _repo.getUsers(params: {'role': roleId, 'page_size': 500}),
      );
    } catch (e) {
      _err(e);
    } finally {
      usersLoading.value = false;
    }
  }

  void onSendToChanged(String mode) {
    sendTo.value = mode;
    selectedRoleId.value = null;
    selectedUsers.clear();
    selectedClassId.value = null;
    selectedSectionId.value = null;
    users.clear();
    sections.clear();
  }

  Future<void> sendEmail() async {
    final title = emailTitleCtrl.text.trim();
    if (title.isEmpty) {
      _warn('Email title is required.');
      return;
    }
    if (emailDescCtrl.text.trim().isEmpty) {
      _warn('Email description is required.');
      return;
    }

    final targetData = <String, dynamic>{};
    if (sendTo.value == 'group') {
      if (selectedRoleId.value == null) {
        _warn('Please select a role/group.');
        return;
      }
      targetData['role_id'] = selectedRoleId.value;
    } else if (sendTo.value == 'individual') {
      if (selectedUsers.isEmpty) {
        _warn('Please select at least one user.');
        return;
      }
      targetData['user_ids'] = selectedUsers.toList();
    } else if (sendTo.value == 'class') {
      if (selectedClassId.value == null) {
        _warn('Please select a class.');
        return;
      }
      targetData['class_id'] = selectedClassId.value;
      if (selectedSectionId.value != null) {
        targetData['section_id'] = selectedSectionId.value;
      }
      targetData['target'] = targetStudentsOrParents.value;
    }

    emailSending.value = true;
    try {
      final data = {
        'title': title,
        'description': emailDescCtrl.text.trim(),
        'send_through': 'email',
        'send_to': sendTo.value,
        'target_data': targetData,
      };
      await _repo.sendEmail(data);
      emailTitleCtrl.clear();
      emailDescCtrl.clear();
      selectedUsers.clear();
      _ok('Email sent successfully.');
      // Refresh logs
      loadEmailLogs();
    } catch (e) {
      _err(e);
    } finally {
      emailSending.value = false;
    }
  }

  // ── Email Logs ────────────────────────────────────────────────────────────

  Future<void> loadEmailLogs() async {
    logsLoading.value = true;
    try {
      emailLogs.assignAll(await _repo.getEmailLogs(params: {'page_size': 500}));
    } catch (e) {
      _err(e);
    } finally {
      logsLoading.value = false;
    }
  }

  // ── Holiday Calendar CRUD ─────────────────────────────────────────────────

  Future<void> loadHolidays() async {
    holidayLoading.value = true;
    try {
      holidays.assignAll(await _repo.getHolidays(params: {'page_size': 500}));
    } catch (e) {
      _err(e);
    } finally {
      holidayLoading.value = false;
    }
  }

  void startHolidayCreate() {
    holidayEditingId.value = null;
    holidayTitleCtrl.clear();
    holidayStartDate.value = DateTime.now();
    holidayEndDate.value = DateTime.now();
    holidayIsActive.value = true;
    showHolidayForm.value = true;
  }

  void startHolidayEdit(HolidayCalendar h) {
    holidayEditingId.value = h.id;
    holidayTitleCtrl.text = h.title;
    holidayStartDate.value = _tryParse(h.startDate);
    holidayEndDate.value = _tryParse(h.endDate);
    holidayIsActive.value = h.isActive;
    showHolidayForm.value = true;
  }

  void cancelHolidayForm() {
    showHolidayForm.value = false;
    holidayEditingId.value = null;
  }

  Future<void> saveHoliday() async {
    final title = holidayTitleCtrl.text.trim();
    if (title.isEmpty) {
      _warn('Holiday title is required.');
      return;
    }
    if (holidayStartDate.value == null) {
      _warn('Start date is required.');
      return;
    }
    if (holidayEndDate.value == null) {
      _warn('End date is required.');
      return;
    }

    holidaySaving.value = true;
    try {
      final data = {
        'title': title,
        'start_date': _fmt(holidayStartDate.value),
        'end_date': _fmt(holidayEndDate.value),
        'is_active': holidayIsActive.value,
      };

      if (holidayEditingId.value == null) {
        final created = await _repo.createHoliday(data);
        holidays.insert(0, created);
        _ok('Holiday created.');
      } else {
        final updated =
            await _repo.updateHoliday(holidayEditingId.value!, data);
        final idx = holidays.indexWhere((h) => h.id == holidayEditingId.value);
        if (idx != -1) holidays[idx] = updated;
        _ok('Holiday updated.');
      }
      cancelHolidayForm();
    } catch (e) {
      _err(e);
    } finally {
      holidaySaving.value = false;
    }
  }

  Future<void> deleteHoliday(int id) async {
    holidayLoading.value = true;
    try {
      await _repo.deleteHoliday(id);
      holidays.removeWhere((h) => h.id == id);
      _ok('Holiday deleted.');
    } catch (e) {
      _err(e);
    } finally {
      holidayLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _fmt(DateTime? d) =>
      d == null ? null : DateFormat('yyyy-MM-dd').format(d);

  DateTime? _tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String roleName(int id) =>
      roles.firstWhereOrNull((r) => r.id == id)?.name ?? 'Role #$id';

  void _ok(String msg) => Get.snackbar('Success', msg,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _warn(String msg) => Get.snackbar('Validation', msg,
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _err(Object e) => Get.snackbar('Error', ApiError.extract(e),
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);
}
