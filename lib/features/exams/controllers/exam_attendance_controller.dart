import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

// ── Attendance Create Controller ──────────────────────────────────────────────

class ExamAttendanceController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedSubjectId = Rx<int?>(null);
  final selectedDate = ''.obs;

  final students = <AttendanceStudent>[].obs;
  final attendanceState = <int, String>{}.obs; // studentRecordId → 'P' | 'A' | 'L'

  final isLoading = false.obs;
  final isSearching = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final successMsg = ''.obs;

  List<SchoolSection> get filteredSections {
    if (selectedClassId.value == null) return [];
    return sections.where((s) => s.classId == selectedClassId.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final data = await _repo.getAttendanceIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      subjects.value = _parseList(data['subjects'], SchoolSubject.fromJson);
    } catch (_) {
      errorMsg.value = 'Failed to load attendance page.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null ||
        selectedClassId.value == null ||
        selectedSectionId.value == null ||
        selectedSubjectId.value == null ||
        selectedDate.value.isEmpty) {
      errorMsg.value = 'All fields are required.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      successMsg.value = '';
      final data = await _repo.searchAttendanceCreate({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
        'subject': selectedSubjectId.value,
        'date': selectedDate.value,
      });
      final rows = _parseList(data['records'], AttendanceStudent.fromJson);
      students.value = rows;
      final next = <int, String>{};
      for (final r in rows) {
        next[r.studentRecordId] = r.attendanceType;
      }
      attendanceState.value = next;
    } catch (e) {
      students.value = [];
      attendanceState.value = {};
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Search failed. ');
    } finally {
      isSearching.value = false;
    }
  }

  void setAttendance(int id, String type) {
    attendanceState[id] = type;
    attendanceState.refresh();
  }

  void markAll(String type) {
    for (final s in students) {
      attendanceState[s.studentRecordId] = type;
    }
    attendanceState.refresh();
  }

  Future<void> save() async {
    if (students.isEmpty) {
      errorMsg.value = 'No students to save.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final records = <Map<String, dynamic>>[];
      for (final s in students) {
        records.add({
          'student_record_id': s.studentRecordId,
          'attendance_type': attendanceState[s.studentRecordId] ?? 'P',
        });
      }
      await _repo.saveAttendance({
        'exam_type_id': selectedExamId.value,
        'subject_id': selectedSubjectId.value,
        'date': selectedDate.value,
        'records': records,
      });
      successMsg.value = 'Attendance saved successfully.';
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Save failed. ');
    } finally {
      isSaving.value = false;
    }
  }
}

// ── Attendance Report Controller ──────────────────────────────────────────────

class ExamAttendanceReportController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedSubjectId = Rx<int?>(null);

  final rows = <AttendanceReportRow>[].obs;

  final isLoading = false.obs;
  final isSearching = false.obs;
  final errorMsg = ''.obs;

  List<SchoolSection> get filteredSections {
    if (selectedClassId.value == null) return [];
    return sections.where((s) => s.classId == selectedClassId.value).toList();
  }

  int get presentCount => rows.where((r) => r.isPresent).length;
  int get absentCount => rows.where((r) => !r.isPresent).length;

  @override
  void onInit() {
    super.onInit();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final data = await _repo.getAttendanceIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      subjects.value = _parseList(data['subjects'], SchoolSubject.fromJson);
    } catch (_) {
      errorMsg.value = 'Failed to load attendance report page.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null ||
        selectedClassId.value == null ||
        selectedSectionId.value == null ||
        selectedSubjectId.value == null) {
      errorMsg.value = 'All fields are required.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      final data = await _repo.searchAttendanceReport({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
        'subject': selectedSubjectId.value,
      });
      rows.value = _parseList(data['records'], AttendanceReportRow.fromJson);
    } catch (e) {
      rows.value = [];
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Search failed. ');
    } finally {
      isSearching.value = false;
    }
  }
}
