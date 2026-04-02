import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrPayrollController extends GetxController {
  final _repo = HrRepository();
  final records = <PayrollRecord>[].obs;
  final activeStaff = <Staff>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final selectedStatusFilter = ''.obs;
  final totalBasic = 0.0.obs;
  final totalAllowance = 0.0.obs;
  final totalDeduction = 0.0.obs;
  final totalNet = 0.0.obs;

  final selectedStaffId = Rx<int?>(null);
  final monthCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final basicSalaryCtrl = TextEditingController(text: '0.00');
  final allowanceCtrl = TextEditingController(text: '0.00');
  final deductionCtrl = TextEditingController(text: '0.00');

  static const statusFilters = ['', 'draft', 'processed', 'paid'];
  static const statusLabels = {'': 'All', 'draft': 'Draft', 'processed': 'Processed', 'paid': 'Paid'};

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    monthCtrl.text = now.month.toString();
    yearCtrl.text = now.year.toString();
    load();
  }

  @override
  void onClose() {
    monthCtrl.dispose(); yearCtrl.dispose(); basicSalaryCtrl.dispose();
    allowanceCtrl.dispose(); deductionCtrl.dispose();
    super.onClose();
  }

  List<PayrollRecord> get filtered {
    final s = selectedStatusFilter.value;
    if (s.isEmpty) return records.toList();
    return records.where((r) => r.status == s).toList();
  }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getPayroll(), _repo.getStaff(), _repo.getPayrollSummary(),
      ]);
      final allStaff = results[1] as List<Staff>;
      // Build id→name map for enriching payroll records that have no name
      final nameById = {for (final s in allStaff) s.id: s.fullName};
      records.value = (results[0] as List<PayrollRecord>).map((r) {
        if (r.staffName.isNotEmpty) return r;
        final name = (r.staffId != null ? nameById[r.staffId] : null) ?? '';
        return r.copyWith(staffName: name.isNotEmpty ? name : 'Staff #${r.staffId}');
      }).toList();
      activeStaff.value = allStaff.where((s) => s.status == 'active').toList();
      final summary = results[2] as Map<String, dynamic>;
      totalBasic.value = double.tryParse(summary['total_basic_salary']?.toString() ?? '0') ?? 0;
      totalAllowance.value = double.tryParse(summary['total_allowance']?.toString() ?? '0') ?? 0;
      totalDeduction.value = double.tryParse(summary['total_deduction']?.toString() ?? '0') ?? 0;
      totalNet.value = double.tryParse(summary['total_net_salary']?.toString() ?? '0') ?? 0;
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isLoading.value = false; }
  }

  void resetForm() {
    selectedStaffId.value = null; basicSalaryCtrl.text = '0.00';
    allowanceCtrl.text = '0.00'; deductionCtrl.text = '0.00'; errorMsg.value = '';
  }

  void prefillSalary() {
    if (selectedStaffId.value == null) return;
    final s = activeStaff.firstWhereOrNull((s) => s.id == selectedStaffId.value);
    if (s != null) basicSalaryCtrl.text = s.basicSalary;
  }

  Future<void> save() async {
    if (selectedStaffId.value == null) { errorMsg.value = 'Please select a staff member.'; return; }
    isSaving.value = true; errorMsg.value = '';
    try {
      await _repo.createPayroll({
        'staff': selectedStaffId.value,
        'payroll_month': int.tryParse(monthCtrl.text) ?? DateTime.now().month,
        'payroll_year': int.tryParse(yearCtrl.text) ?? DateTime.now().year,
        'basic_salary': basicSalaryCtrl.text.trim(),
        'allowance': allowanceCtrl.text.trim(),
        'deduction': deductionCtrl.text.trim(),
      });
      resetForm(); await load();
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isSaving.value = false; }
  }

  Future<void> markPaid(int id) async {
    try { await _repo.markPayrollPaid(id); await load(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
  }
}
