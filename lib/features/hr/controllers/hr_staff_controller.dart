import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';
import 'hr_staff_directory_controller.dart';

class HrStaffController extends GetxController {
  final _repo = HrRepository();
  final departments = <Department>[].obs;
  final designations = <Designation>[].obs;
  final roles = <HrRole>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final editingId = Rx<int?>(null);

  // ── Basic Info ──────────────────────────────────────────────────────────────
  final staffNoCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final fathersNameCtrl = TextEditingController();
  final mothersNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final joinDateCtrl = TextEditingController();
  final emergencyMobileCtrl = TextEditingController();
  final drivingLicenseCtrl = TextEditingController();
  final currentAddressCtrl = TextEditingController();
  final permanentAddressCtrl = TextEditingController();
  final qualificationCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final selectedGender = ''.obs;
  final selectedMaritalStatus = ''.obs;
  final selectedStatus = 'active'.obs;
  final selectedRoleId = Rx<int?>(null);
  final selectedDepartmentId = Rx<int?>(null);
  final selectedDesignationId = Rx<int?>(null);
  final showPublic = false.obs;

  // ── Employment ──────────────────────────────────────────────────────────────
  final basicSalaryCtrl = TextEditingController(text: '0.00');
  final epfNoCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final selectedContractType = ''.obs;

  // ── Bank ────────────────────────────────────────────────────────────────────
  final bankAccountNameCtrl = TextEditingController();
  final bankAccountNoCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankBranchCtrl = TextEditingController();

  // ── Social ──────────────────────────────────────────────────────────────────
  final facebookCtrl = TextEditingController();
  final twitterCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final instagramCtrl = TextEditingController();

  // ── Leave ───────────────────────────────────────────────────────────────────
  final casualLeaveCtrl = TextEditingController(text: '0');
  final medicalLeaveCtrl = TextEditingController(text: '0');
  final maternityLeaveCtrl = TextEditingController(text: '0');

  // ── Document files ──────────────────────────────────────────────────────────
  // *Server: path stored on server (from API).  *Local: newly picked local file path.
  final staffPhotoServer = ''.obs;
  final staffPhotoLocal = ''.obs;
  final staffPhotoName = ''.obs;

  final resumeServer = ''.obs;
  final resumeLocal = ''.obs;
  final resumeName = ''.obs;

  final joiningLetterServer = ''.obs;
  final joiningLetterLocal = ''.obs;
  final joiningLetterName = ''.obs;

  final otherDocServer = ''.obs;
  final otherDocLocal = ''.obs;
  final otherDocName = ''.obs;

  // ── Statics ─────────────────────────────────────────────────────────────────
  static const genderOptions = ['male', 'female', 'other'];
  static const maritalOptions = ['single', 'married'];
  static const statusOptions = ['active', 'inactive', 'terminated'];
  static const contractOptions = ['permanent', 'contract'];

  List<Designation> get filteredDesignations => selectedDepartmentId.value == null
      ? designations.toList()
      : designations.where((d) => d.departmentId == selectedDepartmentId.value).toList();

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    for (final c in [
      staffNoCtrl, firstNameCtrl, lastNameCtrl, emailCtrl, phoneCtrl,
      fathersNameCtrl, mothersNameCtrl, dobCtrl, joinDateCtrl, emergencyMobileCtrl,
      drivingLicenseCtrl, currentAddressCtrl, permanentAddressCtrl,
      qualificationCtrl, experienceCtrl, basicSalaryCtrl, epfNoCtrl, locationCtrl,
      bankAccountNameCtrl, bankAccountNoCtrl, bankNameCtrl, bankBranchCtrl,
      facebookCtrl, twitterCtrl, linkedinCtrl, instagramCtrl,
      casualLeaveCtrl, medicalLeaveCtrl, maternityLeaveCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  // ── Load dropdown data ───────────────────────────────────────────────────────

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getDepartments(isActive: true),
        _repo.getDesignations(isActive: true),
        _repo.getRoles(),
      ]);
      departments.value = results[0] as List<Department>;
      designations.value = results[1] as List<Designation>;
      roles.value = results[2] as List<HrRole>;
      if (editingId.value == null) {
        try {
          staffNoCtrl.text = await _repo.getNextStaffNo();
        } catch (_) {}
      }
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Edit helpers ─────────────────────────────────────────────────────────────

  void startEdit(Staff s) {
    editingId.value = s.id;
    staffNoCtrl.text = s.staffNo;
    firstNameCtrl.text = s.firstName;
    lastNameCtrl.text = s.lastName;
    emailCtrl.text = s.email;
    phoneCtrl.text = s.phone;
    fathersNameCtrl.text = s.fathersName;
    mothersNameCtrl.text = s.mothersName;
    dobCtrl.text = s.dateOfBirth;
    joinDateCtrl.text = s.joinDate;
    emergencyMobileCtrl.text = s.emergencyMobile;
    drivingLicenseCtrl.text = s.drivingLicense;
    currentAddressCtrl.text = s.currentAddress;
    permanentAddressCtrl.text = s.permanentAddress;
    qualificationCtrl.text = s.qualification;
    experienceCtrl.text = s.experience;
    selectedGender.value = s.gender;
    selectedMaritalStatus.value = s.maritalStatus;
    selectedStatus.value = s.status;
    selectedRoleId.value = s.roleId;
    selectedDepartmentId.value = s.departmentId;
    selectedDesignationId.value = s.designationId;
    showPublic.value = s.showPublic;
    basicSalaryCtrl.text = s.basicSalary;
    epfNoCtrl.text = s.epfNo;
    locationCtrl.text = s.location;
    selectedContractType.value = s.contractType;
    bankAccountNameCtrl.text = s.bankAccountName;
    bankAccountNoCtrl.text = s.bankAccountNo;
    bankNameCtrl.text = s.bankName;
    bankBranchCtrl.text = s.bankBranch;
    facebookCtrl.text = s.facebookUrl;
    twitterCtrl.text = s.twitterUrl;
    linkedinCtrl.text = s.linkedinUrl;
    instagramCtrl.text = s.instagramUrl;
    casualLeaveCtrl.text = s.casualLeave.toStringAsFixed(0);
    medicalLeaveCtrl.text = s.medicalLeave.toStringAsFixed(0);
    maternityLeaveCtrl.text = s.maternityLeave.toStringAsFixed(0);

    // Document fields — populate server path, reset local picks
    staffPhotoServer.value = s.staffPhoto;
    staffPhotoLocal.value = '';
    staffPhotoName.value = _basename(s.staffPhoto);

    resumeServer.value = s.resume;
    resumeLocal.value = '';
    resumeName.value = _basename(s.resume);

    joiningLetterServer.value = s.joiningLetter;
    joiningLetterLocal.value = '';
    joiningLetterName.value = _basename(s.joiningLetter);

    otherDocServer.value = s.otherDocument;
    otherDocLocal.value = '';
    otherDocName.value = _basename(s.otherDocument);
  }

  void cancelEdit() {
    editingId.value = null;
    for (final c in [
      firstNameCtrl, lastNameCtrl, emailCtrl, phoneCtrl,
      fathersNameCtrl, mothersNameCtrl, dobCtrl, joinDateCtrl,
      emergencyMobileCtrl, drivingLicenseCtrl, currentAddressCtrl,
      permanentAddressCtrl, qualificationCtrl, experienceCtrl,
      epfNoCtrl, locationCtrl, bankAccountNameCtrl, bankAccountNoCtrl,
      bankNameCtrl, bankBranchCtrl, facebookCtrl, twitterCtrl,
      linkedinCtrl, instagramCtrl,
    ]) {
      c.clear();
    }
    basicSalaryCtrl.text = '0.00';
    casualLeaveCtrl.text = '0';
    medicalLeaveCtrl.text = '0';
    maternityLeaveCtrl.text = '0';
    selectedGender.value = '';
    selectedMaritalStatus.value = '';
    selectedStatus.value = 'active';
    selectedRoleId.value = null;
    selectedDepartmentId.value = null;
    selectedDesignationId.value = null;
    selectedContractType.value = '';
    showPublic.value = false;
    errorMsg.value = '';

    // Reset document file state
    staffPhotoServer.value = ''; staffPhotoLocal.value = ''; staffPhotoName.value = '';
    resumeServer.value = ''; resumeLocal.value = ''; resumeName.value = '';
    joiningLetterServer.value = ''; joiningLetterLocal.value = ''; joiningLetterName.value = '';
    otherDocServer.value = ''; otherDocLocal.value = ''; otherDocName.value = '';

    try {
      _repo.getNextStaffNo().then((v) => staffNoCtrl.text = v);
    } catch (_) {}
  }

  // ── File picking ─────────────────────────────────────────────────────────────

  Future<void> pickFile(String field) async {
    try {
      final isImage = field == 'staffPhoto';
      final result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.first;
      if (f.path == null) return;
      switch (field) {
        case 'staffPhoto':
          staffPhotoLocal.value = f.path!;
          staffPhotoName.value = f.name;
          break;
        case 'resume':
          resumeLocal.value = f.path!;
          resumeName.value = f.name;
          break;
        case 'joiningLetter':
          joiningLetterLocal.value = f.path!;
          joiningLetterName.value = f.name;
          break;
        case 'otherDoc':
          otherDocLocal.value = f.path!;
          otherDocName.value = f.name;
          break;
      }
    } catch (e) {
      errorMsg.value = 'Could not pick file: $e';
    }
  }

  void clearFile(String field) {
    switch (field) {
      case 'staffPhoto':
        staffPhotoLocal.value = '';
        staffPhotoName.value = _basename(staffPhotoServer.value);
        break;
      case 'resume':
        resumeLocal.value = '';
        resumeName.value = _basename(resumeServer.value);
        break;
      case 'joiningLetter':
        joiningLetterLocal.value = '';
        joiningLetterName.value = _basename(joiningLetterServer.value);
        break;
      case 'otherDoc':
        otherDocLocal.value = '';
        otherDocName.value = _basename(otherDocServer.value);
        break;
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────────

  Future<void> save() async {
    if (firstNameCtrl.text.trim().isEmpty) {
      errorMsg.value = 'First name is required.';
      return;
    }
    if (emailCtrl.text.trim().isEmpty) {
      errorMsg.value = 'Email is required.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    final wasEditing = editingId.value != null;
    try {
      final data = <String, dynamic>{
        'staff_no': staffNoCtrl.text.trim(),
        'first_name': firstNameCtrl.text.trim(),
        'last_name': lastNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'fathers_name': fathersNameCtrl.text.trim(),
        'mothers_name': mothersNameCtrl.text.trim(),
        'date_of_birth': dobCtrl.text.trim().isEmpty ? null : dobCtrl.text.trim(),
        'gender': selectedGender.value,
        'marital_status': selectedMaritalStatus.value,
        'emergency_mobile': emergencyMobileCtrl.text.trim(),
        'driving_license': drivingLicenseCtrl.text.trim(),
        'current_address': currentAddressCtrl.text.trim(),
        'permanent_address': permanentAddressCtrl.text.trim(),
        'qualification': qualificationCtrl.text.trim(),
        'experience': experienceCtrl.text.trim(),
        'join_date': joinDateCtrl.text.trim().isEmpty ? null : joinDateCtrl.text.trim(),
        'status': selectedStatus.value,
        'show_public': showPublic.value,
        'basic_salary': basicSalaryCtrl.text.trim(),
        'epf_no': epfNoCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'contract_type': selectedContractType.value,
        'bank_account_name': bankAccountNameCtrl.text.trim(),
        'bank_account_no': bankAccountNoCtrl.text.trim(),
        'bank_name': bankNameCtrl.text.trim(),
        'bank_branch': bankBranchCtrl.text.trim(),
        'facebook_url': facebookCtrl.text.trim(),
        'twitter_url': twitterCtrl.text.trim(),
        'linkedin_url': linkedinCtrl.text.trim(),
        'instagram_url': instagramCtrl.text.trim(),
        'casual_leave': int.tryParse(casualLeaveCtrl.text) ?? 0,
        'medical_leave': int.tryParse(medicalLeaveCtrl.text) ?? 0,
        'maternity_leave': int.tryParse(maternityLeaveCtrl.text) ?? 0,
        if (selectedRoleId.value != null) 'role': selectedRoleId.value,
        if (selectedDepartmentId.value != null) 'department': selectedDepartmentId.value,
        if (selectedDesignationId.value != null) 'designation': selectedDesignationId.value,
      };

      // Build payload — use FormData when new files are picked
      final hasNewFiles = staffPhotoLocal.value.isNotEmpty ||
          resumeLocal.value.isNotEmpty ||
          joiningLetterLocal.value.isNotEmpty ||
          otherDocLocal.value.isNotEmpty;

      dynamic payload;
      if (hasNewFiles) {
        final formMap = Map<String, dynamic>.from(data);
        Future<void> addFile(String key, String localPath, String serverPath) async {
          if (localPath.isNotEmpty) {
            formMap[key] = await dio.MultipartFile.fromFile(
              localPath,
              filename: localPath.split(RegExp(r'[/\\]')).last,
            );
          } else if (serverPath.isNotEmpty) {
            formMap[key] = serverPath;
          }
        }
        await addFile('staff_photo', staffPhotoLocal.value, staffPhotoServer.value);
        await addFile('resume', resumeLocal.value, resumeServer.value);
        await addFile('joining_letter', joiningLetterLocal.value, joiningLetterServer.value);
        await addFile('other_document', otherDocLocal.value, otherDocServer.value);
        payload = dio.FormData.fromMap(formMap);
      } else {
        // No new files — send existing server paths as strings
        data['staff_photo'] = staffPhotoServer.value;
        data['resume'] = resumeServer.value;
        data['joining_letter'] = joiningLetterServer.value;
        data['other_document'] = otherDocServer.value;
        payload = data;
      }

      if (wasEditing) {
        await _repo.updateStaff(editingId.value!, payload);
      } else {
        await _repo.createStaff(payload);
      }

      cancelEdit();
      if (wasEditing) {
        try {
          Get.find<HrStaffDirectoryController>().load();
        } catch (_) {}
        Get.back();
      }
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isSaving.value = false;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  static String _basename(String path) {
    if (path.isEmpty) return '';
    return path.split(RegExp(r'[/\\]')).last;
  }
}
