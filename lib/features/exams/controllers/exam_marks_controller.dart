import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(
    dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

class ExamMarksController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedSubjectId = Rx<int?>(null);

  final parts = <ExamSetupInfo>[].obs;
  final students = <MarksStudentRow>[].obs;

  // Local editable state: studentRecordId -> {setupId -> mark}
  final marksState = <int, Map<String, String>>{}.obs;
  final absentState = <int, bool>{}.obs;
  final remarksState = <int, String>{}.obs;

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
      final data = await _repo.getMarksIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      subjects.value = _parseList(data['subjects'], SchoolSubject.fromJson);
    } catch (e) {
      errorMsg.value = 'Failed to load marks criteria';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null ||
        selectedClassId.value == null ||
        selectedSubjectId.value == null) {
      errorMsg.value = 'Exam, class and subject are required.';
      return;
    }

    try {
      isSearching.value = true;
      errorMsg.value = '';
      successMsg.value = '';

      final data = await _repo.searchMarksCreate({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value ?? 0,
        'subject': selectedSubjectId.value,
      });

      final rows = _parseList(data['students'], MarksStudentRow.fromJson);
      final setupParts =
          _parseList(data['marks_entry_form'], ExamSetupInfo.fromJson);

      students.value = rows;
      parts.value = setupParts;

      final nextMarks = <int, Map<String, String>>{};
      final nextAbsent = <int, bool>{};
      final nextRemarks = <int, String>{};

      for (final row in rows) {
        final rowMarks = <String, String>{};
        for (final part in setupParts) {
          rowMarks[part.id.toString()] =
              row.marks[part.id.toString()] ?? '0';
        }
        nextMarks[row.studentRecordId] = rowMarks;
        nextAbsent[row.studentRecordId] = row.isAbsent;
        nextRemarks[row.studentRecordId] = row.teacherRemarks;
      }

      marksState.value = nextMarks;
      absentState.value = nextAbsent;
      remarksState.value = nextRemarks;
    } catch (e) {
      students.value = [];
      parts.value = [];
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'No Result Found');
    } finally {
      isSearching.value = false;
    }
  }

  void updateMark(int studentRecordId, int setupId, String value) {
    final current = Map<String, String>.from(marksState[studentRecordId] ?? {});
    current[setupId.toString()] = value;
    marksState[studentRecordId] = current;
    marksState.refresh();
  }

  void toggleAbsent(int studentRecordId, bool value) {
    absentState[studentRecordId] = value;
    absentState.refresh();
  }

  void updateRemarks(int studentRecordId, String value) {
    remarksState[studentRecordId] = value;
    remarksState.refresh();
  }

  Future<void> save() async {
    if (selectedExamId.value == null ||
        selectedClassId.value == null ||
        selectedSubjectId.value == null ||
        students.isEmpty ||
        parts.isEmpty) return;

    try {
      isSaving.value = true;
      errorMsg.value = '';

      final sidMap = <int, int>{};
      for (int i = 0; i < parts.length; i++) {
        sidMap[i] = parts[i].id;
      }

      final markStore = <String, dynamic>{};
      for (final s in students) {
        markStore[s.studentRecordId.toString()] = {
          'student': s.student,
          'class': selectedClassId.value,
          'section': s.section,
          'marks': marksState[s.studentRecordId] ?? {},
          'exam_Sids': sidMap,
          'absent_students':
              (absentState[s.studentRecordId] ?? false)
                  ? s.studentRecordId
                  : '',
          'teacher_remarks': remarksState[s.studentRecordId] ?? '',
        };
      }

      await _repo.saveMarks({
        'exam_id': selectedExamId.value,
        'class_id': selectedClassId.value,
        'section_id': selectedSectionId.value ?? 0,
        'subject_id': selectedSubjectId.value,
        'markStore': markStore,
      });

      successMsg.value = 'Marks saved successfully';
      await search();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving.value = false;
    }
  }
}
