import 'package:get/get.dart';
import '../controllers/student_category_controller.dart';
import '../controllers/student_group_controller.dart';
import '../controllers/student_list_controller.dart';
import '../controllers/student_add_controller.dart';
import '../controllers/student_multi_class_controller.dart';
import '../controllers/student_promote_controller.dart';
import '../controllers/student_disabled_controller.dart';
import '../controllers/student_unassigned_controller.dart';
import '../controllers/student_delete_record_controller.dart';

class StudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentCategoryController>(
        () => StudentCategoryController());
    Get.lazyPut<StudentGroupController>(
        () => StudentGroupController());
    Get.lazyPut<StudentListController>(
        () => StudentListController());
    Get.lazyPut<StudentAddController>(
        () => StudentAddController());
    Get.lazyPut<StudentMultiClassController>(
        () => StudentMultiClassController());
    Get.lazyPut<StudentPromoteController>(
        () => StudentPromoteController());
    Get.lazyPut<StudentDisabledController>(
        () => StudentDisabledController());
    Get.lazyPut<StudentUnassignedController>(
        () => StudentUnassignedController());
    Get.lazyPut<StudentDeleteRecordController>(
        () => StudentDeleteRecordController());
  }
}
