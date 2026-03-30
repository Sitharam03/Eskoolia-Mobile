import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class CoreSetupController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  final activeTab = 0.obs; // 0=years 1=classes 2=sections 3=subjects

  // ── Academic Years ──────────────────────────────────────────────────────────
  final years = <AcademicYear>[].obs;
  final yearsLoading = false.obs;
  final yearsError = ''.obs;
  final yearsSaving = false.obs;
  final editingYearId = RxnInt();
  final yearName = ''.obs;
  final yearStartDate = ''.obs;
  final yearEndDate = ''.obs;
  final yearIsCurrent = false.obs;

  // ── Classes ─────────────────────────────────────────────────────────────────
  final classes = <SchoolClass>[].obs;
  final classesLoading = false.obs;
  final classesError = ''.obs;
  final classesSaving = false.obs;
  final editingClassId = RxnInt();
  final className = ''.obs;
  final classOrder = '0'.obs;

  // ── Sections ────────────────────────────────────────────────────────────────
  final sections = <Section>[].obs;
  final sectionsLoading = false.obs;
  final sectionsError = ''.obs;
  final sectionsSaving = false.obs;
  final editingSectionId = RxnInt();
  final sectionClassId = ''.obs;
  final sectionName = ''.obs;
  final sectionCapacity = '0'.obs;

  // ── Subjects ────────────────────────────────────────────────────────────────
  final subjects = <Subject>[].obs;
  final subjectsLoading = false.obs;
  final subjectsError = ''.obs;
  final subjectsSaving = false.obs;
  final editingSubjectId = RxnInt();
  final subjectName = ''.obs;
  final subjectCode = ''.obs;
  final subjectType = 'compulsory'.obs;

  @override
  void onInit() {
    super.onInit();
    loadYears();
    loadClasses();
    loadSections();
    loadSubjects();
  }

  // ── Academic Years ──────────────────────────────────────────────────────────

  Future<void> loadYears() async {
    try {
      yearsLoading.value = true;
      yearsError.value = '';
      years.value = await _repo.getAcademicYears();
    } catch (_) {
      yearsError.value = 'Unable to load academic years.';
    } finally {
      yearsLoading.value = false;
    }
  }

  void startEditYear(AcademicYear y) {
    editingYearId.value = y.id;
    yearName.value = y.name;
    yearStartDate.value = y.startDate;
    yearEndDate.value = y.endDate;
    yearIsCurrent.value = y.isCurrent;
    yearsError.value = '';
  }

  void resetYearForm() {
    editingYearId.value = null;
    yearName.value = '';
    yearStartDate.value = '';
    yearEndDate.value = '';
    yearIsCurrent.value = false;
    yearsError.value = '';
  }

  Future<void> saveYear() async {
    if (yearName.value.trim().isEmpty || yearStartDate.value.isEmpty || yearEndDate.value.isEmpty) {
      yearsError.value = 'Name, start date, and end date are required.';
      return;
    }
    try {
      yearsSaving.value = true;
      yearsError.value = '';
      await _repo.saveAcademicYear({
        'name': yearName.value.trim(),
        'start_date': yearStartDate.value,
        'end_date': yearEndDate.value,
        'is_current': yearIsCurrent.value,
      }, id: editingYearId.value);
      resetYearForm();
      await loadYears();
    } catch (_) {
      yearsError.value = editingYearId.value != null
          ? 'Failed to update academic year.'
          : 'Failed to create academic year.';
    } finally {
      yearsSaving.value = false;
    }
  }

  Future<void> deleteYear(int id) async {
    try {
      yearsError.value = '';
      await _repo.deleteAcademicYear(id);
      if (editingYearId.value == id) resetYearForm();
      await loadYears();
    } catch (_) {
      yearsError.value = 'Failed to delete academic year.';
    }
  }

  // ── Classes ─────────────────────────────────────────────────────────────────

  Future<void> loadClasses() async {
    try {
      classesLoading.value = true;
      classesError.value = '';
      classes.value = await _repo.getClasses();
    } catch (_) {
      classesError.value = 'Unable to load classes.';
    } finally {
      classesLoading.value = false;
    }
  }

  void startEditClass(SchoolClass c) {
    editingClassId.value = c.id;
    className.value = c.name;
    classOrder.value = c.numericOrder.toString();
    classesError.value = '';
  }

  void resetClassForm() {
    editingClassId.value = null;
    className.value = '';
    classOrder.value = '0';
    classesError.value = '';
  }

  Future<void> saveClass() async {
    if (className.value.trim().isEmpty) {
      classesError.value = 'Class name is required.';
      return;
    }
    try {
      classesSaving.value = true;
      classesError.value = '';
      await _repo.saveClass({
        'name': className.value.trim(),
        'numeric_order': int.tryParse(classOrder.value) ?? 0,
      }, id: editingClassId.value);
      resetClassForm();
      await loadClasses();
    } catch (_) {
      classesError.value = editingClassId.value != null
          ? 'Failed to update class.'
          : 'Failed to create class.';
    } finally {
      classesSaving.value = false;
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      classesError.value = '';
      await _repo.deleteClass(id);
      if (editingClassId.value == id) resetClassForm();
      await loadClasses();
      await loadSections(); // sections may have changed
    } catch (_) {
      classesError.value = 'Failed to delete class.';
    }
  }

  // ── Sections ────────────────────────────────────────────────────────────────

  Future<void> loadSections() async {
    try {
      sectionsLoading.value = true;
      sectionsError.value = '';
      sections.value = await _repo.getSections();
    } catch (_) {
      sectionsError.value = 'Unable to load sections.';
    } finally {
      sectionsLoading.value = false;
    }
  }

  void startEditSection(Section s) {
    editingSectionId.value = s.id;
    sectionClassId.value = s.schoolClass.toString();
    sectionName.value = s.name;
    sectionCapacity.value = s.capacity.toString();
    sectionsError.value = '';
  }

  void resetSectionForm() {
    editingSectionId.value = null;
    sectionClassId.value = '';
    sectionName.value = '';
    sectionCapacity.value = '0';
    sectionsError.value = '';
  }

  Future<void> saveSection() async {
    if (sectionClassId.value.isEmpty || sectionName.value.trim().isEmpty) {
      sectionsError.value = 'Class and section name are required.';
      return;
    }
    try {
      sectionsSaving.value = true;
      sectionsError.value = '';
      await _repo.saveSection({
        'school_class': int.parse(sectionClassId.value),
        'name': sectionName.value.trim(),
        'capacity': int.tryParse(sectionCapacity.value) ?? 0,
      }, id: editingSectionId.value);
      resetSectionForm();
      await loadSections();
    } catch (_) {
      sectionsError.value = editingSectionId.value != null
          ? 'Failed to update section.'
          : 'Failed to create section.';
    } finally {
      sectionsSaving.value = false;
    }
  }

  Future<void> deleteSection(int id) async {
    try {
      sectionsError.value = '';
      await _repo.deleteSection(id);
      if (editingSectionId.value == id) resetSectionForm();
      await loadSections();
    } catch (_) {
      sectionsError.value = 'Failed to delete section.';
    }
  }

  // ── Subjects ────────────────────────────────────────────────────────────────

  Future<void> loadSubjects() async {
    try {
      subjectsLoading.value = true;
      subjectsError.value = '';
      subjects.value = await _repo.getSubjects();
    } catch (_) {
      subjectsError.value = 'Unable to load subjects.';
    } finally {
      subjectsLoading.value = false;
    }
  }

  void startEditSubject(Subject s) {
    editingSubjectId.value = s.id;
    subjectName.value = s.name;
    subjectCode.value = s.code;
    subjectType.value = s.subjectType;
    subjectsError.value = '';
  }

  void resetSubjectForm() {
    editingSubjectId.value = null;
    subjectName.value = '';
    subjectCode.value = '';
    subjectType.value = 'compulsory';
    subjectsError.value = '';
  }

  Future<void> saveSubject() async {
    if (subjectName.value.trim().isEmpty) {
      subjectsError.value = 'Subject name is required.';
      return;
    }
    try {
      subjectsSaving.value = true;
      subjectsError.value = '';
      await _repo.saveSubject({
        'name': subjectName.value.trim(),
        'code': subjectCode.value.trim(),
        'subject_type': subjectType.value,
      }, id: editingSubjectId.value);
      resetSubjectForm();
      await loadSubjects();
    } catch (_) {
      subjectsError.value = editingSubjectId.value != null
          ? 'Failed to update subject.'
          : 'Failed to create subject.';
    } finally {
      subjectsSaving.value = false;
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      subjectsError.value = '';
      await _repo.deleteSubject(id);
      if (editingSubjectId.value == id) resetSubjectForm();
      await loadSubjects();
    } catch (_) {
      subjectsError.value = 'Failed to delete subject.';
    }
  }

  String className_(int? id) =>
      id == null ? '-' : (classes.firstWhereOrNull((c) => c.id == id)?.name ?? '#$id');
}
