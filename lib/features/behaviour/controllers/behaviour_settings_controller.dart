import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/behaviour_models.dart';
import '../repositories/behaviour_repository.dart';

class BehaviourSettingsController extends GetxController {
  final BehaviourRepository _repo;
  BehaviourSettingsController(this._repo);

  // ── Settings ─────────────────────────────────────────────────────────────────
  final setting = Rx<BehaviourSetting>(BehaviourSetting.empty);
  final isLoading = true.obs;
  final isSaving = false.obs;

  // ── Support data (shared across all report pages) ─────────────────────────────
  final academicYears = <BAcademicYearRef>[].obs;
  final classes = <BClassRef>[].obs;
  final sections = <BSectionRef>[].obs;

  // ── Shared report filters ─────────────────────────────────────────────────────
  final reportYearId = Rx<int?>(null);
  final reportClassId = Rx<int?>(null);
  final reportSectionId = Rx<int?>(null);
  final reportNameCtrl = TextEditingController();
  final rankPointCtrl = TextEditingController();
  final rankOperator = 'above'.obs; // 'above' | 'below'

  // ── Report loading state ──────────────────────────────────────────────────────
  final reportLoading = false.obs;

  // ── Report data ───────────────────────────────────────────────────────────────
  final incidentReportRows = <StudentIncidentReportRow>[].obs;
  final rankRows = <StudentRankRow>[].obs;
  final classRankRows = <ClassSectionRankRow>[].obs;
  final incidentWiseRows = <IncidentWiseRow>[].obs;

  // ── Helper lookups ────────────────────────────────────────────────────────────
  String yearName(int? id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';
  String className(int? id) =>
      classes.firstWhereOrNull((c) => c.id == id)?.name ?? '-';
  String sectionName(int? id) =>
      sections.firstWhereOrNull((s) => s.id == id)?.name ?? '-';

  List<BSectionRef> get filteredSections {
    if (reportClassId.value != null) {
      return sections.where((s) => s.classId == reportClassId.value).toList();
    }
    return sections;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    reportNameCtrl.dispose();
    rankPointCtrl.dispose();
    super.onClose();
  }

  // ── Load settings + support data ─────────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getSettings(),
        _repo.getAcademicYears(),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      setting.value = results[0] as BehaviourSetting;
      academicYears.assignAll(results[1] as List<BAcademicYearRef>);
      classes.assignAll(results[2] as List<BClassRef>);
      sections.assignAll(results[3] as List<BSectionRef>);
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Shared filter param builder ───────────────────────────────────────────────

  Map<String, dynamic> _baseParams() {
    final params = <String, dynamic>{};
    if (reportYearId.value != null) params['academic_year_id'] = reportYearId.value;
    if (reportClassId.value != null) params['class_id'] = reportClassId.value;
    if (reportSectionId.value != null) params['section_id'] = reportSectionId.value;
    final name = reportNameCtrl.text.trim();
    if (name.isNotEmpty) params['name'] = name;
    return params;
  }

  // ── Individual report loaders ─────────────────────────────────────────────────

  Future<void> loadStudentIncidentReport() async {
    reportLoading.value = true;
    try {
      incidentReportRows.assignAll(
          await _repo.getStudentIncidentReport(params: _baseParams()));
    } catch (e) {
      _err(e);
    } finally {
      reportLoading.value = false;
    }
  }

  Future<void> loadStudentRankReport() async {
    reportLoading.value = true;
    try {
      final params = _baseParams();
      final ptRaw = rankPointCtrl.text.trim();
      if (ptRaw.isNotEmpty) {
        params['point'] = ptRaw;
        params['operator'] = rankOperator.value;
      }
      rankRows.assignAll(
          await _repo.getStudentRankReport(params: params));
    } catch (e) {
      _err(e);
    } finally {
      reportLoading.value = false;
    }
  }

  Future<void> loadClassSectionRankReport() async {
    reportLoading.value = true;
    try {
      classRankRows.assignAll(
          await _repo.getClassSectionRankReport(params: _baseParams()));
    } catch (e) {
      _err(e);
    } finally {
      reportLoading.value = false;
    }
  }

  Future<void> loadIncidentWiseReport() async {
    reportLoading.value = true;
    try {
      incidentWiseRows.assignAll(
          await _repo.getIncidentWiseReport(params: _baseParams()));
    } catch (e) {
      _err(e);
    } finally {
      reportLoading.value = false;
    }
  }

  void resetReportFilters() {
    reportYearId.value = null;
    reportClassId.value = null;
    reportSectionId.value = null;
    reportNameCtrl.clear();
    rankPointCtrl.clear();
    rankOperator.value = 'above';
  }

  // ── Settings save ─────────────────────────────────────────────────────────────

  Future<void> saveSetting({
    required bool studentComment,
    required bool parentComment,
    required bool studentView,
    required bool parentView,
  }) async {
    isSaving.value = true;
    try {
      final updated = await _repo.updateSettings({
        'student_comment': studentComment,
        'parent_comment': parentComment,
        'student_view': studentView,
        'parent_view': parentView,
      });
      setting.value = updated;
      _ok('Settings saved.');
    } catch (e) {
      _err(e);
    } finally {
      isSaving.value = false;
    }
  }

  void _ok(String msg) => Get.snackbar('Success', msg,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void _err(Object e) => Get.snackbar('Error', e.toString(),
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);
}
