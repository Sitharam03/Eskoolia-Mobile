import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class AttendanceRow {
  final Staff staff;
  final selectedType = 'P'.obs;
  final noteCtrl = TextEditingController();
  AttendanceRow(this.staff);
  void dispose() => noteCtrl.dispose();
}

class HrStaffAttendanceController extends GetxController {
  final _repo = HrRepository();
  final activeStaff = <Staff>[].obs;
  final attendanceRows = <AttendanceRow>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final successMsg = ''.obs;
  final selectedDate = ''.obs;
  final reportData = <String, dynamic>{}.obs;

  static const typeOptions = ['P', 'A', 'L', 'F', 'H'];
  static const typeLabels = {'P': 'Present', 'A': 'Absent', 'L': 'Leave', 'F': 'Half Day', 'H': 'Holiday'};

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    load();
  }

  @override
  void onClose() {
    for (final r in attendanceRows) r.dispose();
    super.onClose();
  }

  int get presentCount => attendanceRows.where((r) => r.selectedType.value == 'P').length;
  int get absentCount => attendanceRows.where((r) => r.selectedType.value == 'A').length;
  int get leaveCount => attendanceRows.where((r) => r.selectedType.value == 'L').length;
  int get halfDayCount => attendanceRows.where((r) => r.selectedType.value == 'F').length;
  int get holidayCount => attendanceRows.where((r) => r.selectedType.value == 'H').length;

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = ''; successMsg.value = '';
    try {
      final staffList = await _repo.getStaff(status: 'active');
      activeStaff.value = staffList;
      final existing = await _repo.getAttendanceByDate(selectedDate.value);
      final existingMap = {for (final a in existing) a.staffId: a};
      for (final r in attendanceRows) r.dispose();
      attendanceRows.value = staffList.map((s) {
        final row = AttendanceRow(s);
        final ex = existingMap[s.id];
        if (ex != null) { row.selectedType.value = ex.attendanceType; row.noteCtrl.text = ex.note; }
        return row;
      }).toList();
    } catch (e) { errorMsg.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  Future<void> saveAttendance() async {
    isSaving.value = true; errorMsg.value = ''; successMsg.value = '';
    try {
      final rows = attendanceRows.map((r) => {
        'staff': r.staff.id,
        'attendance_date': selectedDate.value,
        'attendance_type': r.selectedType.value,
        'note': r.noteCtrl.text.trim(),
      }).toList();
      await _repo.bulkStoreAttendance(rows);
      successMsg.value = 'Attendance saved successfully!';
    } catch (e) { errorMsg.value = e.toString(); }
    finally { isSaving.value = false; }
  }
}
