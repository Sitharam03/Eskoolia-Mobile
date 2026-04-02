import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/hr_models.dart';
import '../repositories/hr_repository.dart';

class HrStaffDirectoryController extends GetxController {
  final _repo = HrRepository();
  final staff = <Staff>[].obs;
  final departments = <Department>[].obs;
  final designations = <Designation>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final searchQuery = ''.obs;
  final selectedDeptFilter = Rx<int?>(null);
  final selectedStatusFilter = 'all'.obs;

  static const statusFilters = ['all', 'active', 'inactive', 'terminated'];

  @override
  void onInit() { super.onInit(); load(); }

  List<Staff> get filtered {
    var list = staff.toList();
    if (selectedStatusFilter.value != 'all') {
      list = list.where((s) => s.status == selectedStatusFilter.value).toList();
    }
    if (selectedDeptFilter.value != null) {
      list = list.where((s) => s.departmentId == selectedDeptFilter.value).toList();
    }
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((s) =>
      s.fullName.toLowerCase().contains(q) ||
      s.staffNo.toLowerCase().contains(q) ||
      s.email.toLowerCase().contains(q) ||
      s.phone.contains(q)).toList();
  }

  Future<void> load() async {
    isLoading.value = true; errorMsg.value = '';
    try {
      final results = await Future.wait([
        _repo.getStaff(), _repo.getDepartments(), _repo.getDesignations(),
      ]);
      staff.value = results[0] as List<Staff>;
      departments.value = results[1] as List<Department>;
      designations.value = results[2] as List<Designation>;
    } catch (e) { errorMsg.value = ApiError.extract(e); }
    finally { isLoading.value = false; }
  }

  Future<void> delete(int id) async {
    try { await _repo.deleteStaff(id); await load(); }
    catch (e) { errorMsg.value = ApiError.extract(e); }
  }
}
