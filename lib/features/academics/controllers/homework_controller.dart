import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class HomeworkController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;
  final students = <StudentRecord>[].obs;

  // ── Add homework form ──────────────────────────────────────────────────────
  final academicYearId = ''.obs;
  final addClassId = ''.obs;
  final addSectionId = ''.obs;
  final addSubjectId = ''.obs;
  final homeworkDate = _today().obs;
  final submissionDate = _today().obs;
  final marks = '100'.obs;
  final file = ''.obs;
  final description = ''.obs;
  final isSaving = false.obs;
  final addError = ''.obs;
  final addSuccess = ''.obs;

  // ── Homework list + evaluation ─────────────────────────────────────────────
  final homeworks = <Homework>[].obs;
  final isLoading = false.obs;
  final filterClassId = ''.obs;
  final filterSectionId = ''.obs;
  final filterSubjectId = ''.obs;
  final selectedHomework = Rx<Homework?>(null);
  final evaluationDate = _today().obs;

  // ── Evaluation drafts: studentId → {complete_status, marks, note} ─────────
  final drafts = RxMap<int, Map<String, String>>();
  final savingEval = false.obs;
  final evalError = ''.obs;

  // ── Report ─────────────────────────────────────────────────────────────────
  final reportRows = <Map<String, dynamic>>[].obs;
  final reportClassId = ''.obs;
  final reportSectionId = ''.obs;
  final reportSubjectId = ''.obs;
  final isReportLoading = false.obs;
  final reportError = ''.obs;

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Section> get addAvailableSections =>
      sections.where((s) => s.schoolClass == int.tryParse(addClassId.value)).toList();

  List<Section> get filterSections =>
      sections.where((s) => s.schoolClass == int.tryParse(filterClassId.value)).toList();

  List<Section> get reportSections =>
      sections.where((s) => s.schoolClass == int.tryParse(reportClassId.value)).toList();

  List<StudentRecord> get filteredStudents {
    final hw = selectedHomework.value;
    if (hw == null) return [];
    return students.where((st) {
      return st.currentClass == hw.classId &&
          (hw.sectionId == null || st.currentSection == hw.sectionId);
    }).toList();
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
    loadHomeworks();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _repo.getAcademicYears(),
      _repo.getClasses(),
      _repo.getSections(),
      _repo.getSubjects(),
      _repo.getStudents(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    subjects.value = results[3] as List<Subject>;
    students.value = results[4] as List<StudentRecord>;
    if (academicYearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      academicYearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  // ── Add homework ───────────────────────────────────────────────────────────

  Future<void> submitHomework() async {
    if (addClassId.isEmpty || addSubjectId.isEmpty) {
      addError.value = 'Class and subject are required.';
      return;
    }
    try {
      isSaving.value = true;
      addError.value = '';
      addSuccess.value = '';
      await _repo.createHomework({
        'academic_year_id': academicYearId.isNotEmpty ? int.parse(academicYearId.value) : null,
        'class_id': int.parse(addClassId.value),
        'section_id': addSectionId.isNotEmpty ? int.parse(addSectionId.value) : null,
        'subject_id': int.parse(addSubjectId.value),
        'homework_date': homeworkDate.value,
        'submission_date': submissionDate.value,
        'marks': marks.value.isNotEmpty ? int.tryParse(marks.value) : 0,
        'description': description.value.trim(),
        'file': file.value.isNotEmpty ? file.value : null,
      });
      addSuccess.value = 'Homework added successfully.';
      _resetAddForm();
      await loadHomeworks();
    } catch (_) {
      addError.value = 'Failed to add homework.';
    } finally {
      isSaving.value = false;
    }
  }

  void _resetAddForm() {
    addClassId.value = '';
    addSectionId.value = '';
    addSubjectId.value = '';
    homeworkDate.value = _today();
    submissionDate.value = _today();
    marks.value = '100';
    file.value = '';
    description.value = '';
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Future<void> loadHomeworks() async {
    try {
      isLoading.value = true;
      homeworks.value = await _repo.getHomeworks(
        classId: filterClassId.value.isEmpty ? null : filterClassId.value,
        sectionId: filterSectionId.value.isEmpty ? null : filterSectionId.value,
        subjectId: filterSubjectId.value.isEmpty ? null : filterSubjectId.value,
      );
    } catch (_) {
      // silently fail
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHomework(int id) async {
    try {
      await _repo.deleteHomework(id);
      await loadHomeworks();
    } catch (_) {
      addError.value = 'Failed to delete homework.';
    }
  }

  // ── Evaluation ─────────────────────────────────────────────────────────────

  Future<void> openEvaluation(Homework homework) async {
    selectedHomework.value = homework;
    evaluationDate.value = homework.evaluationDate ?? _today();
    drafts.clear();
    evalError.value = '';

    try {
      // positional argument — matches repo signature
      final submissions = await _repo.getHomeworkSubmissions(homework.id);
      for (final sub in submissions) {
        drafts[sub.studentId] = {
          'complete_status': sub.completeStatus,
          'marks': sub.marks.toString(),
          'note': sub.note,
        };
      }
    } catch (_) {
      // start with empty drafts
    }
  }

  void setDraft(int studentId, String field, String value) {
    final current = Map<String, String>.from(drafts[studentId] ?? {});
    current[field] = value;
    drafts[studentId] = current;
  }

  Future<void> saveEvaluation() async {
    final hw = selectedHomework.value;
    if (hw == null) return;
    try {
      savingEval.value = true;
      evalError.value = '';
      final studentList = filteredStudents;
      for (final student in studentList) {
        final draft = drafts[student.id] ?? {};
        final existingSubmission = await _repo.getHomeworkSubmissions(hw.id);
        final existing = existingSubmission
            .firstWhereOrNull((s) => s.studentId == student.id);
        await _repo.saveHomeworkSubmission(
          {
            'homework_id': hw.id,
            'student_id': student.id,
            'marks': int.tryParse(draft['marks'] ?? '0') ?? 0,
            'complete_status': draft['complete_status'] ?? 'P',
            'note': draft['note'] ?? '',
          },
          id: existing?.id,
        );
      }
      await _repo.patchHomework(hw.id, {'evaluation_date': evaluationDate.value});
      await loadHomeworks();
      selectedHomework.value = null;
    } catch (_) {
      evalError.value = 'Failed to save evaluation.';
    } finally {
      savingEval.value = false;
    }
  }

  // ── Report ─────────────────────────────────────────────────────────────────

  Future<void> loadReport() async {
    try {
      isReportLoading.value = true;
      reportError.value = '';
      final hwList = await _repo.getHomeworks(
        classId: reportClassId.value.isEmpty ? null : reportClassId.value,
        sectionId: reportSectionId.value.isEmpty ? null : reportSectionId.value,
        subjectId: reportSubjectId.value.isEmpty ? null : reportSubjectId.value,
      );
      final rows = <Map<String, dynamic>>[];
      for (final hw in hwList) {
        final submissions = await _repo.getHomeworkSubmissions(hw.id);
        rows.add({
          'homework': hw,
          'completed': submissions.where((s) => s.completeStatus == 'C').length,
          'incomplete': submissions.where((s) => s.completeStatus == 'I').length,
          'pending': submissions.where((s) => s.completeStatus == 'P').length,
          'total': submissions.length,
        });
      }
      reportRows.value = rows;
    } catch (_) {
      reportError.value = 'Failed to load homework report.';
    } finally {
      isReportLoading.value = false;
    }
  }
}
