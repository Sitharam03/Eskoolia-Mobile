import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

class ExamAdmitCardController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);

  final students = <AdmitCardStudent>[].obs;
  final selectedMap = <int, bool>{}.obs;
  final oldIds = <int>[].obs;
  final setting = Rx<AdmitCardSetting?>(null);

  final isLoading = false.obs;
  final isSearching = false.obs;
  final isGenerating = false.obs;
  final errorMsg = ''.obs;
  final successMsg = ''.obs;

  List<SchoolSection> get filteredSections {
    if (selectedClassId.value == null) return [];
    return sections.where((s) => s.classId == selectedClassId.value).toList();
  }

  bool get allSelected =>
      students.isNotEmpty && students.every((s) => selectedMap[s.studentRecordId] == true);

  @override
  void onInit() {
    super.onInit();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repo.getAdmitCardIndex(),
        _repo.getAdmitCardSetting(),
      ]);
      final data = results[0];
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      final settingData = results[1]['setting'];
      if (settingData is Map<String, dynamic>) {
        setting.value = AdmitCardSetting.fromJson(settingData);
      }
    } catch (_) {
      errorMsg.value = 'Failed to load admit card page.';
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
      successMsg.value = '';
      final data = await _repo.searchAdmitCard({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
      });
      final rows = _parseList(data['records'], AdmitCardStudent.fromJson);
      final ids = (data['old_admit_ids'] as List?)?.map((e) => e as int).toList() ?? [];
      students.value = rows;
      oldIds.value = ids;
      final next = <int, bool>{};
      for (final r in rows) {
        next[r.studentRecordId] = ids.contains(r.studentRecordId);
      }
      selectedMap.value = next;
    } catch (e) {
      students.value = [];
      oldIds.value = [];
      selectedMap.value = {};
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Search failed.');
    } finally {
      isSearching.value = false;
    }
  }

  void toggleStudent(int id, bool value) {
    selectedMap[id] = value;
    selectedMap.refresh();
  }

  void toggleAll(bool value) {
    for (final s in students) {
      selectedMap[s.studentRecordId] = value;
    }
    selectedMap.refresh();
  }

  Future<void> generate() async {
    try {
      isGenerating.value = true;
      errorMsg.value = '';
      final data = <String, dynamic>{};
      selectedMap.forEach((id, checked) {
        if (checked) {
          data[id.toString()] = {'student_record_id': id, 'checked': 1};
        }
      });
      await _repo.generateAdmitCard({
        'exam_type_id': selectedExamId.value,
        'data': data,
      });
      successMsg.value = 'Admit cards generated successfully';
      await search();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Generate failed.');
    } finally {
      isGenerating.value = false;
    }
  }
}

// ── Seat Plan Controller (same pattern) ──────────────────────────────────────

class ExamSeatPlanController extends GetxController {
  final _repo = ExamRepository();

  final examTypes = <ExamType>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;

  final selectedExamId = Rx<int?>(null);
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);

  final students = <AdmitCardStudent>[].obs;
  final selectedMap = <int, bool>{}.obs;
  final oldIds = <int>[].obs;
  final setting = Rx<AdmitCardSetting?>(null);

  final isLoading = false.obs;
  final isSearching = false.obs;
  final isGenerating = false.obs;
  final errorMsg = ''.obs;
  final successMsg = ''.obs;

  List<SchoolSection> get filteredSections {
    if (selectedClassId.value == null) return [];
    return sections.where((s) => s.classId == selectedClassId.value).toList();
  }

  bool get allSelected =>
      students.isNotEmpty && students.every((s) => selectedMap[s.studentRecordId] == true);

  @override
  void onInit() {
    super.onInit();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repo.getSeatPlanIndex(),
        _repo.getSeatPlanSetting(),
      ]);
      final data = results[0];
      examTypes.value = _parseList(data['exams'], ExamType.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      final settingData = results[1]['setting'];
      if (settingData is Map<String, dynamic>) {
        setting.value = AdmitCardSetting.fromJson(settingData);
      }
    } catch (_) {
      errorMsg.value = 'Failed to load seat plan page.';
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
      successMsg.value = '';
      final data = await _repo.searchSeatPlan({
        'exam': selectedExamId.value,
        'class': selectedClassId.value,
        'section': selectedSectionId.value,
      });
      final rows = _parseList(data['records'], AdmitCardStudent.fromJson);
      final ids = (data['seat_plan_ids'] as List?)?.map((e) => e as int).toList() ?? [];
      students.value = rows;
      oldIds.value = ids;
      final next = <int, bool>{};
      for (final r in rows) {
        next[r.studentRecordId] = ids.contains(r.studentRecordId);
      }
      selectedMap.value = next;
    } catch (e) {
      students.value = [];
      oldIds.value = [];
      selectedMap.value = {};
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Search failed.');
    } finally {
      isSearching.value = false;
    }
  }

  void toggleStudent(int id, bool value) {
    selectedMap[id] = value;
    selectedMap.refresh();
  }

  void toggleAll(bool value) {
    for (final s in students) {
      selectedMap[s.studentRecordId] = value;
    }
    selectedMap.refresh();
  }

  Future<void> generate() async {
    try {
      isGenerating.value = true;
      errorMsg.value = '';
      final data = <String, dynamic>{};
      selectedMap.forEach((id, checked) {
        if (checked) {
          data[id.toString()] = {'student_record_id': id, 'checked': 1};
        }
      });
      await _repo.generateSeatPlan({
        'exam_type_id': selectedExamId.value,
        'data': data,
      });
      successMsg.value = 'Seat plan generated successfully';
      await search();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Generate failed.');
    } finally {
      isGenerating.value = false;
    }
  }
}
