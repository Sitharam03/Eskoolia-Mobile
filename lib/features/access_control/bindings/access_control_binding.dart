import 'package:get/get.dart';
import '../repositories/access_control_repository.dart';
import '../controllers/role_controller.dart';
import '../controllers/assign_permission_controller.dart';
import '../controllers/login_permission_controller.dart';
import '../controllers/due_fees_permission_controller.dart';

class AccessControlBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<AccessControlRepository>(() => AccessControlRepository());

    // Controllers
    Get.lazyPut<RoleController>(() => RoleController(
          repository: Get.find<AccessControlRepository>(),
        ));
    Get.lazyPut<AssignPermissionController>(() => AssignPermissionController(
          repository: Get.find<AccessControlRepository>(),
        ));
    Get.lazyPut<LoginPermissionController>(() => LoginPermissionController(
          repository: Get.find<AccessControlRepository>(),
        ));
    Get.lazyPut<DueFeesPermissionController>(() => DueFeesPermissionController(
          repository: Get.find<AccessControlRepository>(),
        ));
  }
}
