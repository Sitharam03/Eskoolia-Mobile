import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

class ExamScheduleReportController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);

  final rows = <ScheduleReportRow>[].obs;

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
      final data = await _repo.getExamScheduleIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
    } catch (_) {
      errorMsg.value = 'Failed to load schedule report page.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null) {
      errorMsg.value = 'Please select an exam.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      final data = await _repo.searchScheduleReport({
        'exam': selectedExamId.value,
        if (selectedClassId.value != null) 'class': selectedClassId.value,
        if (selectedSectionId.value != null) 'section': selectedSectionId.value,
      });
      rows.value = _parseList(data['records'], ScheduleReportRow.fromJson);
    } catch (e) {
      rows.value = [];
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Search failed. ');
    } finally {
      isSearching.value = false;
    }
  }
}
