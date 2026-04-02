import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

// ── Merit Report Controller ───────────────────────────────────────────────────

class ExamMeritReportController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);

  final rows = <MeritRow>[].obs;

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
      final data = await _repo.getExamReportIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Failed to load report page.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null || selectedClassId.value == null || selectedSectionId.value == null) {
      errorMsg.value = 'Exam, class and section are required.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      final data = await _repo.searchMeritReport({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
      });
      rows.value = _parseList(data['records'], MeritRow.fromJson);
    } catch (e) {
      rows.value = [];
      errorMsg.value = ApiError.extract(e, 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }
}

// ── Student Report Controller ─────────────────────────────────────────────────

class ExamStudentReportController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final students = <SimpleStudent>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedStudentId = Rx<int?>(null);

  final rows = <StudentReportRow>[].obs;
  String studentName = '';
  String totalMarks = '';
  String averageGpa = '';
  String overallGrade = '';

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
      final data = await _repo.getExamReportIndex();
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      students.value = _parseList(data['students'], SimpleStudent.fromJson);
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Failed to load student report page.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search() async {
    if (selectedExamId.value == null || selectedStudentId.value == null) {
      errorMsg.value = 'Exam and student are required.';
      return;
    }
    try {
      isSearching.value = true;
      errorMsg.value = '';
      final data = await _repo.searchStudentReport({
        'exam': selectedExamId.value,
        'student': selectedStudentId.value,
      });
      rows.value = _parseList(data['records'], StudentReportRow.fromJson);
      studentName = data['student_name'] as String? ?? '';
      totalMarks = (data['total_marks'] ?? '').toString();
      averageGpa = (data['average_gpa'] ?? '').toString();
      overallGrade = data['overall_grade'] as String? ?? '';
    } catch (e) {
      rows.value = [];
      errorMsg.value = ApiError.extract(e, 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  List<SimpleStudent> get filteredStudents {
    if (selectedClassId.value == null && selectedSectionId.value == null) return students;
    return students.where((s) {
      final classMatch = selectedClassId.value == null || s.classId == selectedClassId.value;
      final sectionMatch = selectedSectionId.value == null || s.sectionId == selectedSectionId.value;
      return classMatch && sectionMatch;
    }).toList();
  }
}
