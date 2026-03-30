import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/exam_models.dart';
import '../repositories/exam_repository.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  return [];
}

class OnlineExamController extends GetxController {
  final _repo = ExamRepository();

  final exams = <OnlineExam>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;

  // Form fields
  final titleCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final totalMarkCtrl = TextEditingController();
  final passMarkCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final selectedClassId = Rx<int?>(null);
  final selectedSectionId = Rx<int?>(null);
  final selectedSubjectId = Rx<int?>(null);
  final editingId = Rx<int?>(null);

  final isLoading = false.obs;
  final isSaving = false.obs;
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

  @override
  void onClose() {
    titleCtrl.dispose();
    durationCtrl.dispose();
    totalMarkCtrl.dispose();
    passMarkCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    super.onClose();
  }

  Future<void> refresh() => _loadIndex();

  Future<void> _loadIndex() async {
    try {
      isLoading.value = true;
      final data = await _repo.getOnlineExamIndex();
      exams.value = _parseList(data['exams'], OnlineExam.fromJson);
      classes.value = _parseList(data['classes'], SchoolClass.fromJson);
      sections.value = _parseList(data['sections'], SchoolSection.fromJson);
      subjects.value = _parseList(data['subjects'], SchoolSubject.fromJson);
    } catch (_) {
      errorMsg.value = 'Failed to load online exams.';
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(OnlineExam e) {
    editingId.value = e.id;
    titleCtrl.text = e.title;
    durationCtrl.text = e.duration.toString();
    totalMarkCtrl.text = e.totalMark.toString();
    passMarkCtrl.text = e.passMark.toString();
    startDateCtrl.text = e.startDate;
    endDateCtrl.text = e.endDate;
    selectedClassId.value = e.classId;
    selectedSectionId.value = e.sectionId;
    selectedSubjectId.value = e.subjectId;
  }

  void cancelEdit() {
    editingId.value = null;
    titleCtrl.clear();
    durationCtrl.clear();
    totalMarkCtrl.clear();
    passMarkCtrl.clear();
    startDateCtrl.clear();
    endDateCtrl.clear();
    selectedClassId.value = null;
    selectedSectionId.value = null;
    selectedSubjectId.value = null;
    errorMsg.value = '';
  }

  Future<void> save() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty ||
        selectedClassId.value == null ||
        selectedSubjectId.value == null ||
        startDateCtrl.text.isEmpty ||
        endDateCtrl.text.isEmpty) {
      errorMsg.value = 'Title, class, subject, start & end date are required.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'title': title,
        'duration': int.tryParse(durationCtrl.text.trim()) ?? 0,
        'total_mark': int.tryParse(totalMarkCtrl.text.trim()) ?? 0,
        'pass_mark': int.tryParse(passMarkCtrl.text.trim()) ?? 0,
        'start_date': startDateCtrl.text.trim(),
        'end_date': endDateCtrl.text.trim(),
        'class': selectedClassId.value,
        if (selectedSectionId.value != null) 'section': selectedSectionId.value,
        'subject': selectedSubjectId.value,
      };
      if (editingId.value != null) {
        await _repo.updateOnlineExam({...payload, 'id': editingId.value});
        successMsg.value = 'Online exam updated.';
      } else {
        await _repo.createOnlineExam(payload);
        successMsg.value = 'Online exam created.';
      }
      cancelEdit();
      await _loadIndex();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Save failed. ');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteOnlineExam(id);
      await _loadIndex();
    } catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', 'Delete failed. ');
    }
  }

  Future<void> togglePublish(OnlineExam e) async {
    try {
      if (e.isPublished) {
        await _repo.cancelPublishOnlineExam(e.id);
      } else {
        await _repo.publishOnlineExam(e.id);
      }
      await _loadIndex();
    } catch (err) {
      errorMsg.value = err.toString().replaceFirst('Exception: ', 'Action failed. ');
    }
  }
}
