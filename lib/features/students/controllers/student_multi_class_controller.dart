import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_model.dart';
import '../models/multi_class_record_model.dart';
import '../repositories/students_repository.dart';

class StudentMultiClassController extends GetxController {
  final _repo = StudentsRepository();

  final students = <StudentRow>[].obs;
  final classes = <Map<String, dynamic>>[].obs;
  final sections = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchQuery = ''.obs;

  final selectedStudent = Rxn<StudentRow>();
  final records = <MultiClassRecord>[].obs;
  final isLoadingRecords = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getStudents(queryParams: {'page_size': 1000, 'is_active': 'true'}),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      students.value = results[0] as List<StudentRow>;
      classes.value = results[1] as List<Map<String, dynamic>>;
      sections.value = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load data'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentRow> get filteredStudents {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return students;
    return students
        .where((s) =>
            s.fullName.toLowerCase().contains(q) ||
            s.admissionNo.toLowerCase().contains(q) ||
            (s.rollNo?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<void> selectStudent(StudentRow student) async {
    selectedStudent.value = student;
    isLoadingRecords.value = true;
    try {
      records.value = await _repo.getMultiClassRecords(student.id);
    } catch (_) {
      records.value = [];
    } finally {
      isLoadingRecords.value = false;
    }
  }

  void addRecord() {
    records.add(const MultiClassRecord(
      schoolClass: 0,
      isDefault: false,
    ));
  }

  void removeRecord(int index) {
    if (index >= 0 && index < records.length) {
      records.removeAt(index);
    }
  }

  void updateRecord(int index, MultiClassRecord updated) {
    if (index >= 0 && index < records.length) {
      records[index] = updated;
    }
  }

  void setDefault(int index) {
    final updated = records
        .asMap()
        .entries
        .map((e) => e.value.copyWith(isDefault: e.key == index))
        .toList();
    records.value = updated;
  }

  List<Map<String, dynamic>> sectionsForClass(int classId) {
    return sections.where((s) => s['school_class'] == classId).toList();
  }

  String className(int id) {
    return classes.firstWhereOrNull((c) => c['id'] == id)?['name'] as String? ??
        '—';
  }

  String sectionName(int? id) {
    if (id == null) return '—';
    return sections.firstWhereOrNull((s) => s['id'] == id)?['name']
            as String? ??
        '—';
  }

  Future<void> saveRecords() async {
    final student = selectedStudent.value;
    if (student == null) return;

    // Validate
    for (final r in records) {
      if (r.schoolClass == 0) {
        Get.snackbar('Validation', 'Please select a class for all records',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    isSaving.value = true;
    try {
      await _repo.bulkSaveMultiClassRecords(
        student.id,
        records.map((r) => r.toJson()).toList(),
      );
      Get.snackbar('Success', 'Multi-class records saved',
          snackPosition: SnackPosition.BOTTOM);
      await selectStudent(student);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to save records'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  void clearSelection() {
    selectedStudent.value = null;
    records.clear();
  }
}
