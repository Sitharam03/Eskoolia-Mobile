import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/student_model.dart';
import '../models/student_category_model.dart';
import '../models/guardian_model.dart';
import '../repositories/students_repository.dart';

class StudentAddController extends GetxController {
  final _repo = StudentsRepository();

  // ── Form fields ─────────────────────────────────────────────────────────
  final admissionNoCtrl = TextEditingController();
  final rollNoCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  // Reactive selects
  final selectedGender = ''.obs;
  final selectedBloodGroup = Rxn<String>();
  final selectedCategoryId = Rxn<int>();
  final selectedGuardianId = Rxn<int>();
  final selectedClassId = Rxn<int>();
  final selectedSectionId = Rxn<int>();
  final isDisabled = false.obs;
  final isActive = true.obs;

  // ── Guardian quick-add fields ───────────────────────────────────────────
  final guardianNameCtrl = TextEditingController();
  final guardianRelationCtrl = TextEditingController();
  final guardianPhoneCtrl = TextEditingController();
  final guardianEmailCtrl = TextEditingController();
  final showGuardianForm = false.obs;

  // ── Data lists ──────────────────────────────────────────────────────────
  final categories = <StudentCategory>[].obs;
  final guardians = <Guardian>[].obs;
  final classes = <Map<String, dynamic>>[].obs;
  final sections = <Map<String, dynamic>>[].obs;

  // ── State ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSaving = false.obs;
  final editingId = Rxn<int>();

  static const List<String> genderOptions = ['male', 'female', 'other'];
  static const List<String> bloodGroupOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    admissionNoCtrl.dispose();
    rollNoCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    dobCtrl.dispose();
    guardianNameCtrl.dispose();
    guardianRelationCtrl.dispose();
    guardianPhoneCtrl.dispose();
    guardianEmailCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getGuardians(),
        _repo.getClasses(),
        _repo.getSections(),
      ]);
      categories.value = results[0] as List<StudentCategory>;
      guardians.value = results[1] as List<Guardian>;
      classes.value = results[2] as List<Map<String, dynamic>>;
      sections.value = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to load form data'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredSections {
    if (selectedClassId.value == null) return sections;
    return sections
        .where((s) => s['school_class'] == selectedClassId.value)
        .toList();
  }

  void startEdit(StudentRow student) {
    editingId.value = student.id;
    admissionNoCtrl.text = student.admissionNo;
    rollNoCtrl.text = student.rollNo ?? '';
    firstNameCtrl.text = student.firstName;
    lastNameCtrl.text = student.lastName ?? '';
    dobCtrl.text = student.dateOfBirth ?? '';
    selectedGender.value = student.gender;
    selectedBloodGroup.value = student.bloodGroup;
    selectedCategoryId.value = student.category;
    selectedGuardianId.value = student.guardian;
    selectedClassId.value = student.currentClass;
    selectedSectionId.value = student.currentSection;
    isDisabled.value = student.isDisabled;
    isActive.value = student.isActive;
  }

  void resetForm() {
    editingId.value = null;
    admissionNoCtrl.clear();
    rollNoCtrl.clear();
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    dobCtrl.clear();
    selectedGender.value = '';
    selectedBloodGroup.value = null;
    selectedCategoryId.value = null;
    selectedGuardianId.value = null;
    selectedClassId.value = null;
    selectedSectionId.value = null;
    isDisabled.value = false;
    isActive.value = true;
    showGuardianForm.value = false;
    guardianNameCtrl.clear();
    guardianRelationCtrl.clear();
    guardianPhoneCtrl.clear();
    guardianEmailCtrl.clear();
  }

  Future<bool> saveStudent() async {
    final admNo = admissionNoCtrl.text.trim();
    final fName = firstNameCtrl.text.trim();
    if (admNo.isEmpty || fName.isEmpty || selectedGender.value.isEmpty) {
      Get.snackbar('Validation',
          'Admission No, First Name and Gender are required',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isSaving.value = true;
    try {
      final data = <String, dynamic>{
        'admission_no': admNo,
        if (rollNoCtrl.text.isNotEmpty) 'roll_no': rollNoCtrl.text.trim(),
        'first_name': fName,
        if (lastNameCtrl.text.isNotEmpty)
          'last_name': lastNameCtrl.text.trim(),
        if (dobCtrl.text.isNotEmpty) 'date_of_birth': dobCtrl.text.trim(),
        'gender': selectedGender.value,
        if (selectedBloodGroup.value != null)
          'blood_group': selectedBloodGroup.value,
        if (selectedCategoryId.value != null)
          'category': selectedCategoryId.value,
        if (selectedGuardianId.value != null)
          'guardian': selectedGuardianId.value,
        if (selectedClassId.value != null)
          'current_class': selectedClassId.value,
        if (selectedSectionId.value != null)
          'current_section': selectedSectionId.value,
        'is_disabled': isDisabled.value,
        'is_active': isActive.value,
      };

      if (editingId.value != null) {
        await _repo.updateStudent(editingId.value!, data);
        Get.snackbar('Success', 'Student updated successfully',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await _repo.createStudent(data);
        Get.snackbar('Success', 'Student added successfully',
            snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
      return true;
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to save student'),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveGuardianInline() async {
    if (guardianNameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Guardian name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isSaving.value = true;
    try {
      final g = await _repo.createGuardian({
        'full_name': guardianNameCtrl.text.trim(),
        'relation': guardianRelationCtrl.text.trim(),
        'phone': guardianPhoneCtrl.text.trim(),
        if (guardianEmailCtrl.text.isNotEmpty)
          'email': guardianEmailCtrl.text.trim(),
      });
      guardians.add(g);
      selectedGuardianId.value = g.id;
      guardianNameCtrl.clear();
      guardianRelationCtrl.clear();
      guardianPhoneCtrl.clear();
      guardianEmailCtrl.clear();
      showGuardianForm.value = false;
      Get.snackbar('Success', 'Guardian created',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', ApiError.extract(e, 'Failed to create guardian'),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
