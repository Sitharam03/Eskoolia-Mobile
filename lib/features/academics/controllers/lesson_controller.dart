import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class LessonController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;

  // State
  final lessons = <Lesson>[].obs;
  final groups = <LessonGroup>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // Form - filter / scope
  final academicYearId = ''.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final subjectId = ''.obs;

  // Add form
  final lessonText = ''.obs;
  final isSaving = false.obs;

  // Inline edit
  final editingId = RxnInt();
  final editingTitle = ''.obs;

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Section> get filteredSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  String className(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');

  String sectionName(int? id) =>
      id == null ? '-' : (sections.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String subjectName(int? id) =>
      id == null ? '-' : (subjects.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _repo.getAcademicYears(),
      _repo.getClasses(),
      _repo.getSections(),
      _repo.getSubjects(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    subjects.value = results[3] as List<Subject>;
    if (academicYearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      academicYearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  Future<void> loadLessons() async {
    if (classId.isEmpty || subjectId.isEmpty) return;
    try {
      isLoading.value = true;
      error.value = '';
      final all = await _repo.getLessons(classId: classId.value);
      lessons.value = all.where((l) {
        final sMatch = sectionId.isEmpty || l.sectionId == null ||
            l.sectionId.toString() == sectionId.value;
        final subMatch = subjectId.isEmpty ||
            l.subjectId.toString() == subjectId.value;
        return sMatch && subMatch;
      }).toList();
    } catch (_) {
      error.value = 'Unable to load lessons.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroups() async {
    try {
      groups.value = await _repo.getLessonGroups();
    } catch (_) {
      // silently fail
    }
  }

  Future<void> submitLessons() async {
    if (classId.isEmpty || subjectId.isEmpty) {
      error.value = 'Class and subject are required.';
      return;
    }
    final text = lessonText.value.trim();
    if (text.isEmpty) {
      error.value = 'Please enter at least one lesson title.';
      return;
    }
    final titles = text
        .split('\n')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (titles.isEmpty) {
      error.value = 'No valid lesson titles found.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      await _repo.createLessons({
        'academic_year_id': academicYearId.isNotEmpty ? int.parse(academicYearId.value) : null,
        'class_id': int.parse(classId.value),
        'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
        'subject_id': int.parse(subjectId.value),
        'lesson': titles,
      });
      message.value = '${titles.length} lesson(s) added.';
      lessonText.value = '';
      await loadLessons();
      await loadGroups();
    } catch (_) {
      error.value = 'Failed to add lessons.';
    } finally {
      isSaving.value = false;
    }
  }

  void startEdit(Lesson lesson) {
    editingId.value = lesson.id;
    editingTitle.value = lesson.lessonTitle;
    error.value = '';
    message.value = '';
  }

  Future<void> saveEdit(Lesson lesson) async {
    final newTitle = editingTitle.value.trim();
    if (newTitle.isEmpty) {
      error.value = 'Title cannot be empty.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      await _repo.updateLesson(lesson.id, {'lesson_title': newTitle});
      editingId.value = null;
      editingTitle.value = '';
      message.value = 'Lesson updated.';
      await loadLessons();
    } catch (_) {
      error.value = 'Failed to update lesson.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteLesson(int id) async {
    try {
      error.value = '';
      await _repo.deleteLesson(id);
      await loadLessons();
      await loadGroups();
    } catch (_) {
      error.value = 'Failed to delete lesson.';
    }
  }

  Future<void> deleteGroup() async {
    if (classId.isEmpty || subjectId.isEmpty) return;
    try {
      error.value = '';
      await _repo.deleteLessonGroup(
        classId: classId.value,
        sectionId: sectionId.value,
        subjectId: subjectId.value,
      );
      await loadLessons();
      await loadGroups();
    } catch (_) {
      error.value = 'Failed to delete lesson group.';
    }
  }
}
