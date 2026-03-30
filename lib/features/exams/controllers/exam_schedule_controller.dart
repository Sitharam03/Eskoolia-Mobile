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

class ExamScheduleController extends GetxController {
  final _repo = ExamRepository();

  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final examTypes = <ExamType>[].obs;
  final teachers = <SchoolTeacher>[].obs;
  final periods = <ExamPeriod>[].obs;

  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedExamTypeId = Rx<int?>(null);

  final subjects = <SchoolSubject>[].obs;
  final routineRows = <RoutineRow>[].obs;
  final existingRoutines = <ExistingRoutine>[].obs;

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
      final data = await _repo.getExamScheduleIndex();
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      examTypes.value = _parseList(data['exam_types'], ExamType.fromJson);
      teachers.value = _parseList(data['teachers'], SchoolTeacher.fromJson);
      periods.value = _parseList(data['exam_periods'], ExamPeriod.fromJson);
    } catch (e) {
      errorMsg.value = 'Failed to load schedule criteria';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedClassId.value == null || selectedExamTypeId.value == null) {
      errorMsg.value = 'Exam type and class are required.';
      return;
    }

    try {
      isSearching.value = true;
      errorMsg.value = '';
      successMsg.value = '';

      final data = await _repo.searchExamSchedule({
        'exam_type': selectedExamTypeId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value ?? 0,
      });

      final subjectList =
          _parseList(data['subjects'], SchoolSubject.fromJson);
      final scheduleList =
          _parseList(data['exam_schedule'], ExistingRoutine.fromJson);

      subjects.value = subjectList;
      existingRoutines.value = scheduleList;

      final today = DateTime.now().toIso8601String().substring(0, 10);
      routineRows.value = subjectList.map((subject) {
        final ex = scheduleList
            .where((r) => r.id == subject.id)
            .firstOrNull;
        return RoutineRow(
          section: selectedSectionId.value,
          subject: subject.id,
          teacherId: null,
          examPeriodId: null,
          date: today,
          startTime: '09:00',
          endTime: '10:00',
          room: ex?.room ?? '',
        );
      }).toList();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'No Result Found');
      subjects.value = [];
      routineRows.value = [];
      existingRoutines.value = [];
    } finally {
      isSearching.value = false;
    }
  }

  void updateRow(int index, RoutineRow updated) {
    routineRows[index] = updated;
    routineRows.refresh();
  }

  Future<void> save() async {
    if (selectedClassId.value == null ||
        selectedExamTypeId.value == null ||
        routineRows.isEmpty) {
      errorMsg.value = 'Search and prepare routine rows first.';
      return;
    }

    try {
      isSaving.value = true;
      errorMsg.value = '';
      successMsg.value = '';

      await _repo.saveExamSchedule({
        'class_id': selectedClassId.value,
        'section_id': selectedSectionId.value ?? 0,
        'exam_type_id': selectedExamTypeId.value,
        'routine': routineRows
            .map((row) => {
                  'section': row.section ?? 0,
                  'subject': row.subject,
                  'teacher_id': row.teacherId ?? 0,
                  'exam_period_id': row.examPeriodId ?? 0,
                  'date': row.date,
                  'start_time': row.startTime,
                  'end_time': row.endTime,
                  'room': row.room,
                })
            .toList(),
      });

      successMsg.value = 'Exam routine saved successfully';
      await search();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving.value = false;
    }
  }
}
