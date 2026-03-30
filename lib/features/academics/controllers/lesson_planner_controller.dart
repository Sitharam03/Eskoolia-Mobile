import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class LessonPlannerController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;
  final subjects = <Subject>[].obs;
  final classPeriods = <ClassPeriod>[].obs;
  final teachers = <Teacher>[].obs;
  final allLessons = <Lesson>[].obs;
  final topicDetails = <LessonTopicDetail>[].obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final planners = <PlannerRow>[].obs;
  final overviewItems = <PlannerRow>[].obs;
  final weekly = Rx<WeeklyPlanner?>(null);
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // ── Form ───────────────────────────────────────────────────────────────────
  final academicYearId = ''.obs;
  final day = '1'.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final subjectId = ''.obs;
  final lessonId = ''.obs;
  final lessonDate = ''.obs;
  final routineId = ''.obs;
  final classPeriodId = ''.obs;
  final teacherId = ''.obs;
  final topicId = ''.obs;
  final subTopic = ''.obs;
  final customizeMode = false.obs;
  final customTopicIds = ''.obs;   // comma-separated ids when customizeMode
  final customSubTopics = ''.obs;  // newline-separated subtopics when customizeMode
  final editingPlannerId = RxnInt();
  final weeklyStartDate = ''.obs;
  final isSaving = false.obs;

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

  List<LessonTopicDetail> get filteredTopics {
    final lid = int.tryParse(lessonId.value);
    if (lid == null) return topicDetails.toList();
    return topicDetails.where((t) => t.lesson == lid).toList();
  }

  String className(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');

  String sectionName(int? id) =>
      id == null ? '-' : (sections.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String subjectName(int? id) =>
      id == null ? '-' : (subjects.firstWhereOrNull((s) => s.id == id)?.name ?? '#$id');

  String lessonTitle(int? id) =>
      id == null ? '-' : (allLessons.firstWhereOrNull((l) => l.id == id)?.lessonTitle ?? '#$id');

  String topicTitle(int? id) =>
      id == null ? '-' : (topicDetails.firstWhereOrNull((t) => t.id == id)?.topicTitle ?? '#$id');

  String teacherName(int? id) =>
      id == null ? '-' : (teachers.firstWhereOrNull((t) => t.id == id)?.displayName ?? '#$id');

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
      _repo.getClassPeriods(),
      _repo.getTeachers(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    subjects.value = results[3] as List<Subject>;
    classPeriods.value = results[4] as List<ClassPeriod>;
    teachers.value = results[5] as List<Teacher>;
    if (academicYearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      academicYearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
    await Future.wait([_loadAllLessons(), _loadAllTopics()]);
  }

  Future<void> _loadAllLessons() async {
    try {
      allLessons.value = await _repo.getLessons();
    } catch (_) {}
  }

  Future<void> _loadAllTopics() async {
    try {
      topicDetails.value = await _repo.getLessonTopicDetails();
    } catch (_) {}
  }

  // ── Load data ──────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    await Future.wait([
      loadPlanners(),
      loadOverview(),
      loadWeekly(),
    ]);
  }

  Future<void> loadPlanners() async {
    try {
      isLoading.value = true;
      error.value = '';
      planners.value = await _repo.getLessonPlanners();
    } catch (_) {
      error.value = 'Unable to load lesson planners.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOverview() async {
    try {
      overviewItems.value = await _repo.getLessonPlannerOverview();
    } catch (_) {}
  }

  Future<void> loadWeekly() async {
    try {
      weekly.value = await _repo.getLessonPlannerWeekly(
        teacherId: teacherId.value.isEmpty ? null : teacherId.value,
        startDate: weeklyStartDate.value.isEmpty ? null : weeklyStartDate.value,
      );
    } catch (_) {}
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> submitPlanner() async {
    if (classId.isEmpty || subjectId.isEmpty || lessonDate.isEmpty) {
      error.value = 'Class, subject, and lesson date are required.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';

      final Map<String, dynamic> payload = {
        'academic_year_id': academicYearId.isNotEmpty ? int.parse(academicYearId.value) : null,
        'day': day.value.isNotEmpty ? int.tryParse(day.value) : null,
        'class_id': int.parse(classId.value),
        'section_id': sectionId.isNotEmpty ? int.parse(sectionId.value) : null,
        'subject_id': int.parse(subjectId.value),
        'lesson_id': lessonId.isNotEmpty ? int.parse(lessonId.value) : null,
        'lesson_date': lessonDate.value,
        'routine_id': routineId.isNotEmpty ? int.tryParse(routineId.value) : null,
        'class_period_id': classPeriodId.isNotEmpty ? int.tryParse(classPeriodId.value) : null,
        'teacher_id': teacherId.isNotEmpty ? int.parse(teacherId.value) : null,
      };

      if (customizeMode.value) {
        // Customize mode: multiple topics / subtopics
        payload['customize'] = 'customize';
        final topicIdList = customTopicIds.value
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => int.tryParse(s))
            .where((v) => v != null)
            .toList();
        final subTopicList = customSubTopics.value
            .split('\n')
            .map((s) => s.trim())
            .toList();
        payload['topic'] = topicIdList;
        payload['sub_topic'] = subTopicList;
      } else {
        // Single topic
        payload['topic'] = topicId.isNotEmpty ? int.tryParse(topicId.value) : null;
        payload['sub_topic'] = subTopic.value.isNotEmpty ? subTopic.value : null;
      }

      if (editingPlannerId.value != null) {
        await _repo.updateLessonPlanner(editingPlannerId.value!, payload);
        message.value = 'Lesson plan updated.';
      } else {
        await _repo.createLessonPlanner(payload);
        message.value = 'Lesson plan saved.';
      }
      resetForm();
      await loadAll();
    } catch (_) {
      error.value = 'Failed to save lesson planner.';
    } finally {
      isSaving.value = false;
    }
  }

  void fillPlannerForm(PlannerRow row) {
    editingPlannerId.value = row.id;
    academicYearId.value = row.academicYearId?.toString() ?? '';
    day.value = row.day?.toString() ?? '1';
    classId.value = row.classId.toString();
    sectionId.value = row.sectionId?.toString() ?? '';
    subjectId.value = row.subjectId.toString();
    lessonId.value = row.lessonDetailId.toString();
    lessonDate.value = row.lessonDate ?? '';
    routineId.value = row.routineId?.toString() ?? '';
    classPeriodId.value = row.classPeriodId?.toString() ?? '';
    teacherId.value = row.teacherId?.toString() ?? '';
    topicId.value = row.topicDetailId?.toString() ?? '';
    subTopic.value = row.subTopic ?? '';
    customizeMode.value = false;
    customTopicIds.value = '';
    customSubTopics.value = '';
    error.value = '';
    message.value = '';
  }

  void resetForm() {
    editingPlannerId.value = null;
    day.value = '1';
    classId.value = '';
    sectionId.value = '';
    subjectId.value = '';
    lessonId.value = '';
    lessonDate.value = '';
    routineId.value = '';
    classPeriodId.value = '';
    teacherId.value = '';
    topicId.value = '';
    subTopic.value = '';
    customizeMode.value = false;
    customTopicIds.value = '';
    customSubTopics.value = '';
    error.value = '';
    message.value = '';
  }

  Future<void> deletePlanner(int id) async {
    try {
      error.value = '';
      await _repo.deleteLessonPlanner(id);
      await loadPlanners();
    } catch (_) {
      error.value = 'Failed to delete lesson plan.';
    }
  }
}
