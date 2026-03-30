import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class TopicController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;
  final allLessons = <Lesson>[].obs;

  // State
  final topicGroups = <LessonTopicGroup>[].obs;
  final topicDetails = <LessonTopicDetail>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // Scope / filter
  final academicYearId = ''.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final subjectId = ''.obs;
  final lessonId = ''.obs;

  // Add form
  final topicText = ''.obs;
  final isSaving = false.obs;

  // Inline edit
  final editingTopicId = RxnInt();
  final editingTopicTitle = ''.obs;

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Section> get filteredSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  List<Lesson> get filteredLessons => allLessons.where((l) {
        final cMatch = classId.isEmpty || l.classId.toString() == classId.value;
        final sMatch = sectionId.isEmpty ||
            l.sectionId == null ||
            l.sectionId.toString() == sectionId.value;
        final subMatch = subjectId.isEmpty || l.subjectId.toString() == subjectId.value;
        return cMatch && sMatch && subMatch;
      }).toList();

  String lessonTitle(int? id) =>
      id == null ? '-' : (allLessons.firstWhereOrNull((l) => l.id == id)?.lessonTitle ?? '#$id');

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
    // Load all lessons for the dropdowns
    await _loadAllLessons();
  }

  Future<void> _loadAllLessons() async {
    try {
      allLessons.value = await _repo.getLessons();
    } catch (_) {
      // non-critical
    }
  }

  Future<void> loadTopicGroups() async {
    try {
      isLoading.value = true;
      error.value = '';
      topicGroups.value = await _repo.getLessonTopicGroups();
    } catch (_) {
      error.value = 'Unable to load topic groups.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTopicDetails() async {
    try {
      isLoading.value = true;
      error.value = '';
      topicDetails.value = await _repo.getLessonTopicDetails();
    } catch (_) {
      error.value = 'Unable to load topic details.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitTopics() async {
    if (classId.isEmpty || subjectId.isEmpty || lessonId.isEmpty) {
      error.value = 'Class, subject, and lesson are required.';
      return;
    }
    final text = topicText.value.trim();
    if (text.isEmpty) {
      error.value = 'Please enter at least one topic title.';
      return;
    }
    final titles = text
        .split('\n')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (titles.isEmpty) {
      error.value = 'No valid topic titles found.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      await _repo.createLessonTopics({
        'academic_year_id': academicYearId.isNotEmpty ? int.parse(academicYearId.value) : null,
        'class_id': int.parse(classId.value),
        'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
        'subject_id': int.parse(subjectId.value),
        'lesson_id': int.parse(lessonId.value),
        'topic': titles,
      });
      message.value = '${titles.length} topic(s) added.';
      topicText.value = '';
      await Future.wait([loadTopicGroups(), loadTopicDetails()]);
    } catch (_) {
      error.value = 'Failed to add topics.';
    } finally {
      isSaving.value = false;
    }
  }

  void startEditTopic(LessonTopicDetail topicDetail) {
    editingTopicId.value = topicDetail.id;
    editingTopicTitle.value = topicDetail.topicTitle;
    error.value = '';
    message.value = '';
  }

  Future<void> saveTopicTitle() async {
    final id = editingTopicId.value;
    if (id == null) return;
    final newTitle = editingTopicTitle.value.trim();
    if (newTitle.isEmpty) {
      error.value = 'Topic title cannot be empty.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      await _repo.patchLessonTopicDetail(id, {'topic_title': newTitle});
      editingTopicId.value = null;
      editingTopicTitle.value = '';
      message.value = 'Topic updated.';
      await loadTopicDetails();
    } catch (_) {
      error.value = 'Failed to update topic.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteTopicDetail(int id) async {
    try {
      error.value = '';
      await _repo.deleteLessonTopicDetail(id);
      await Future.wait([loadTopicGroups(), loadTopicDetails()]);
    } catch (_) {
      error.value = 'Failed to delete topic.';
    }
  }

  Future<void> deleteTopicGroup(int groupId) async {
    try {
      error.value = '';
      await _repo.deleteLessonTopicGroup(groupId);
      await Future.wait([loadTopicGroups(), loadTopicDetails()]);
    } catch (_) {
      error.value = 'Failed to delete topic group.';
    }
  }
}
