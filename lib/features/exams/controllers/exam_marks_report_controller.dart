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

class ExamMarksReportController extends GetxController {
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
  final rows = <MarksRegisterRow>[].obs;

  final isLoading = false.obs;
  final isSearching = false.obs;
  final errorMsg = ''.obs;

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
      errorMsg.value = 'Failed to load criteria';
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

      final data = await _repo.searchMarksReport({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value ?? 0,
        'subject': selectedSubjectId.value,
      });

      rows.value =
          _parseList(data['marks_registers'], MarksRegisterRow.fromJson);
      parts.value =
          _parseList(data['marks_entry_form'], ExamSetupInfo.fromJson);
    } catch (e) {
      rows.value = [];
      parts.value = [];
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'No Result Found');
    } finally {
      isSearching.value = false;
    }
  }
}
