import 'package:get/get.dart';
import '../controllers/hr_department_controller.dart';
import '../controllers/hr_designation_controller.dart';
import '../controllers/hr_staff_controller.dart';
import '../controllers/hr_staff_directory_controller.dart';
import '../controllers/hr_leave_type_controller.dart';
import '../controllers/hr_leave_define_controller.dart';
import '../controllers/hr_leave_request_controller.dart';
import '../controllers/hr_staff_attendance_controller.dart';
import '../controllers/hr_payroll_controller.dart';

class HrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HrDepartmentController>(() => HrDepartmentController());
    Get.lazyPut<HrDesignationController>(() => HrDesignationController());
    Get.lazyPut<HrStaffController>(() => HrStaffController());
    Get.lazyPut<HrStaffDirectoryController>(() => HrStaffDirectoryController());
    Get.lazyPut<HrLeaveTypeController>(() => HrLeaveTypeController());
    Get.lazyPut<HrLeaveDefineController>(() => HrLeaveDefineController());
    Get.lazyPut<HrLeaveRequestController>(() => HrLeaveRequestController());
    Get.lazyPut<HrStaffAttendanceController>(() => HrStaffAttendanceController());
    Get.lazyPut<HrPayrollController>(() => HrPayrollController());
  }
}
