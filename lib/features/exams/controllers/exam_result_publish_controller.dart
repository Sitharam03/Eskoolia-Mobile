import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

class ExamResultPublishController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);

  final result = Rx<ResultPublishInfo?>(null);

  final isLoading = false.obs;
  final isSearching = false.obs;
  final isPublishing = false.obs;
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
      final data = await _repo.getResultPublishIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Failed to load result publish page.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null || selectedClassId.value == null) {
      errorMsg.value = 'Exam and class are required.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      successMsg.value = '';
      result.value = null;
      final data = await _repo.searchResultPublish({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        if (selectedSectionId.value != null) 'section': selectedSectionId.value,
      });
      final raw = data['result'] ?? data;
      if (raw is Map<String, dynamic>) {
        result.value = ResultPublishInfo.fromJson(raw);
      }
    } catch (e) {
      result.value = null;
      errorMsg.value = ApiError.extract(e, 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> publish() async {
    if (selectedExamId.value == null || selectedClassId.value == null) {
      errorMsg.value = 'Please search first.';
      return;
    }
    try {
      isPublishing.value = true;
      errorMsg.value = '';
      await _repo.publishResult({
        'exam_type_id': selectedExamId.value,
        'class_id': selectedClassId.value,
        if (selectedSectionId.value != null) 'section_id': selectedSectionId.value,
        'publish': 1,
      });
      successMsg.value = 'Result published successfully.';
      await search();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Publish failed');
    } finally {
      isPublishing.value = false;
    }
  }

  Future<void> unpublish() async {
    if (selectedExamId.value == null || selectedClassId.value == null) {
      errorMsg.value = 'Please search first.';
      return;
    }
    try {
      isPublishing.value = true;
      errorMsg.value = '';
      await _repo.publishResult({
        'exam_type_id': selectedExamId.value,
        'class_id': selectedClassId.value,
        if (selectedSectionId.value != null) 'section_id': selectedSectionId.value,
        'publish': 0,
      });
      successMsg.value = 'Result unpublished.';
      await search();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unpublish failed');
    } finally {
      isPublishing.value = false;
    }
  }
}
