import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

class ExamSetupController extends GetxController {
  final _repo = ExamRepository();

  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;
  final examTypes = <ExamType>[].obs;

  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedSubjectId = Rx<int?>(null);
  final selectedExamTermId = Rx<int?>(null);
  final totalExamMark = '0'.obs;

  // Rows of mark distribution
  final rows = <_SetupRow>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final successMsg = ''.obs;
  final errorMsg = ''.obs;

  List<SchoolSection> get filteredSections {
    if (selectedClassId.value == null) return [];
    return sections.where((s) => s.classId == selectedClassId.value).toList();
  }

  double get totalMark =>
      rows.fold(0, (sum, r) => sum + (double.tryParse(r.examMark) ?? 0));

  @override
  void onInit() {
    super.onInit();
    _loadIndex();
    _autoSearch();
  }

  void _autoSearch() {
    ever(selectedClassId, (_) => _searchExisting());
    ever(selectedSectionId, (_) => _searchExisting());
    ever(selectedSubjectId, (_) => _searchExisting());
    ever(selectedExamTermId, (_) => _searchExisting());
  }

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final data = await _repo.getExamSetupIndex();
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      subjects.value = _parseList(data['subjects'], SchoolSubject.fromJson);
      examTypes.value = _parseList(data['exam_types'], ExamType.fromJson);
      if (rows.isEmpty) rows.add(_SetupRow());
    } catch (e) {
      errorMsg.value = 'Failed to load exam setup criteria';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _searchExisting() async {
    final cId = selectedClassId.value;
    final sId = selectedSectionId.value;
    final subId = selectedSubjectId.value;
    final eId = selectedExamTermId.value;
    if (cId == null || sId == null || subId == null || eId == null) return;

    try {
      final data = await _repo.searchExamSetup(
        classId: cId,
        sectionId: sId,
        subjectId: subId,
        examTermId: eId,
      );
      final items = data['items'];
      if (items is List && items.isNotEmpty) {
        rows.value = items
            .map((i) => _SetupRow.fromJson(i as Map<String, dynamic>))
            .toList();
        totalExamMark.value = (data['totalMark'] ?? '0').toString();
      }
    } catch (_) {
      // Keep empty form if no setup found
    }
  }

  void addRow() => rows.add(_SetupRow());

  void removeRow(int index) {
    if (rows.length > 1) rows.removeAt(index);
  }

  void updateRowTitle(int index, String value) {
    rows[index].examTitle = value;
    rows.refresh();
  }

  void updateRowMark(int index, String value) {
    rows[index].examMark = value;
    rows.refresh();
  }

  Future<void> save() async {
    errorMsg.value = '';
    successMsg.value = '';

    if (selectedClassId.value == null ||
        selectedSectionId.value == null ||
        selectedSubjectId.value == null ||
        selectedExamTermId.value == null) {
      errorMsg.value = 'Class, section, subject and exam term are required.';
      return;
    }
    if (rows.any((r) => r.examTitle.trim().isEmpty)) {
      errorMsg.value = 'Each exam title is required.';
      return;
    }

    try {
      isSaving.value = true;
      await _repo.saveExamSetup({
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
        'subject': selectedSubjectId.value,
        'exam_term_id': selectedExamTermId.value,
        'total_exam_mark':
            double.tryParse(totalExamMark.value)?.toStringAsFixed(2) ?? '0.00',
        'totalMark': totalMark.toStringAsFixed(2),
        'exam_title': rows.map((r) => r.examTitle.trim()).toList(),
        'exam_mark': rows
            .map((r) =>
                (double.tryParse(r.examMark) ?? 0).toStringAsFixed(2))
            .toList(),
      });
      successMsg.value = 'Operation successful';
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving.value = false;
    }
  }
}

class _SetupRow {
  String examTitle;
  String examMark;
  _SetupRow({this.examTitle = '', this.examMark = '0'});
  factory _SetupRow.fromJson(Map<String, dynamic> json) =>
      _SetupRow(
        examTitle: json['exam_title'] as String? ?? '',
        examMark: (json['exam_mark'] ?? '0').toString(),
      );
}

List<T> _parseList<T>(
    dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}
