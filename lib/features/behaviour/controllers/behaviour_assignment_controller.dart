import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_error.dart';
import '../models/behaviour_models.dart';
import '../repositories/behaviour_repository.dart';

class BehaviourAssignmentController extends GetxController {
  final BehaviourRepository _repo;
  BehaviourAssignmentController(this._repo);

  // Support data
  final academicYears = <BAcademicYearRef>[].obs;
  final classes = <BClassRef>[].obs;
  final sections = <BSectionRef>[].obs;
  final allStudents = <BStudentRef>[].obs;
  final incidents = <Incident>[].obs;

  // ── Assignments list state ────────────────────────────────────────────────────
  final assignments = <AssignedIncident>[].obs;
  final isLoading = true.obs;

  // Filters for assignment list
  final filterYearId = Rx<int?>(null);
  final filterClassId = Rx<int?>(null);
  final filterSectionId = Rx<int?>(null);
  final filterIncidentId = Rx<int?>(null);
  final searchCtrl = TextEditingController();

  // ── Bulk assign form ──────────────────────────────────────────────────────────
  final assignYearId = Rx<int?>(null);
  final assignClassId = Rx<int?>(null);
  final assignSectionId = Rx<int?>(null);
  final selectedStudentIds = <int>[].obs;
  final selectedIncidentIds = <int>[].obs;
  final bulkLoading = false.obs;

  /// Students filtered by the selected class/section in the Assign form.
  /// Reads `assignClassId.value` and `assignSectionId.value` so Obx rebuilds
  /// automatically when either changes.
  List<BStudentRef> get filteredStudents {
    final classId = assignClassId.value;
    final sectionId = assignSectionId.value;

    if (classId == null && sectionId == null) return allStudents;

    return allStudents.where((s) {
      final classMatch =
          classId == null || s.currentClassId == classId;
      final sectionMatch =
          sectionId == null || s.currentSectionId == sectionId;
      return classMatch && sectionMatch;
    }).toList();
  }

  // Helper lookups
  String yearName(int? id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';
  String className(int? id) =>
      classes.firstWhereOrNull((c) => c.id == id)?.name ?? '-';
  String sectionName(int? id) =>
      sections.firstWhereOrNull((s) => s.id == id)?.name ?? '-';
  String incidentName(int id) =>
      incidents.firstWhereOrNull((i) => i.id == id)?.title ?? '-';

  List<BSectionRef> get filteredSections {
    if (filterClassId.value != null) {
      return sections.where((s) => s.classId == filterClassId.value).toList();
    }
    return sections;
  }

  List<BSectionRef> get assignSections {
    if (assignClassId.value != null) {
      return sections.where((s) => s.classId == assignClassId.value).toList();
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
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getClasses(),
        _repo.getSections(),
        _repo.getStudents(),
        _repo.getIncidents(params: {'page_size': 500}),
        _repo.getAssignments(params: {'page_size': 1000}),
      ]);
      academicYears.assignAll(results[0] as List<BAcademicYearRef>);
      classes.assignAll(results[1] as List<BClassRef>);
      sections.assignAll(results[2] as List<BSectionRef>);
      allStudents.assignAll(results[3] as List<BStudentRef>);
      incidents.assignAll(results[4] as List<Incident>);
      assignments.assignAll(results[5] as List<AssignedIncident>);
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters() async {
    isLoading.value = true;
    try {
      final params = <String, dynamic>{'page_size': 1000};
      if (filterYearId.value != null) params['academic_year_id'] = filterYearId.value;
      if (filterClassId.value != null) params['class_id'] = filterClassId.value;
      if (filterSectionId.value != null) params['section_id'] = filterSectionId.value;
      if (filterIncidentId.value != null) params['incident_id'] = filterIncidentId.value;
      final name = searchCtrl.text.trim();
      if (name.isNotEmpty) params['name'] = name;

      assignments.assignAll(await _repo.getAssignments(params: params));
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    filterYearId.value = null;
    filterClassId.value = null;
    filterSectionId.value = null;
    filterIncidentId.value = null;
    searchCtrl.clear();
    loadAll();
  }

  // ── Bulk Assign ──────────────────────────────────────────────────────────────

  void toggleStudent(int id) {
    if (selectedStudentIds.contains(id)) {
      selectedStudentIds.remove(id);
    } else {
      selectedStudentIds.add(id);
    }
  }

  void toggleIncident(int id) {
    if (selectedIncidentIds.contains(id)) {
      selectedIncidentIds.remove(id);
    } else {
      selectedIncidentIds.add(id);
    }
  }

  void selectAllStudents() {
    final ids = filteredStudents.map((s) => s.id).toList();
    selectedStudentIds.assignAll(ids);
  }

  void clearStudents() => selectedStudentIds.clear();
  void clearIncidents() => selectedIncidentIds.clear();

  Future<void> submitBulkAssign() async {
    if (selectedStudentIds.isEmpty) {
      _warn('Select at least one student.');
      return;
    }
    if (selectedIncidentIds.isEmpty) {
      _warn('Select at least one incident.');
      return;
    }
    bulkLoading.value = true;
    try {
      final data = <String, dynamic>{
        'student_ids': selectedStudentIds.toList(),
        'incident_ids': selectedIncidentIds.toList(),
      };
      if (assignYearId.value != null) data['academic_year_id'] = assignYearId.value;
      if (assignClassId.value != null) data['class_id'] = assignClassId.value;
      if (assignSectionId.value != null) data['section_id'] = assignSectionId.value;

      final result = await _repo.assignBulk(data);
      final created = result['created'] ?? 0;
      final skipped = result['skipped'] ?? 0;
      _ok('Assigned $created records. Skipped $skipped duplicates.');
      selectedStudentIds.clear();
      selectedIncidentIds.clear();
      await loadAll();
    } catch (e) {
      _err(e);
    } finally {
      bulkLoading.value = false;
    }
  }

  // ── Assignment delete ────────────────────────────────────────────────────────

  Future<void> deleteAssignment(int id) async {
    isLoading.value = true;
    try {
      await _repo.deleteAssignment(id);
      assignments.removeWhere((a) => a.id == id);
      _ok('Assignment deleted.');
    } catch (e) {
      _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Comments ─────────────────────────────────────────────────────────────────

  /// Adds a comment to an assignment. [text] comes from the per-card local
  /// controller in the view so that multiple expanded cards don't share state.
  Future<void> addComment(int assignmentId, String text) async {
    if (text.isEmpty) {
      _warn('Comment cannot be empty.');
      return;
    }
    try {
      final comment = await _repo.createComment({
        'assigned_incident': assignmentId,
        'comment': text,
      });
      // Update the assignment in list with the new comment prepended
      final idx = assignments.indexWhere((a) => a.id == assignmentId);
      if (idx != -1) {
        final old = assignments[idx];
        assignments[idx] = AssignedIncident(
          id: old.id,
          academicYear: old.academicYear,
          incident: old.incident,
          incidentTitle: old.incidentTitle,
          student: old.student,
          studentName: old.studentName,
          record: old.record,
          classId: old.classId,
          sectionId: old.sectionId,
          point: old.point,
          assignedBy: old.assignedBy,
          comments: [comment, ...old.comments],
          createdAt: old.createdAt,
        );
      }
      _ok('Comment added.');
    } catch (e) {
      _err(e);
    }
  }

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
