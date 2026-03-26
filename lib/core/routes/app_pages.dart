import 'package:get/get.dart';
import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/access_control/bindings/access_control_binding.dart';
import '../../features/access_control/views/roles_view.dart';
import '../../features/access_control/views/assign_permission_view.dart';
import '../../features/access_control/views/login_permission_view.dart';
import '../../features/access_control/views/due_fees_login_permission_view.dart';
import '../routes/app_routes.dart';

/// GetX page route table.
/// Add new module routes here as each module is converted.
class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: AppRoutes.roles,
      page: () => const RolesView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.assignPermissionRoot,
      page: () => const AssignPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.assignPermission,
      page: () => const AssignPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.loginPermission,
      page: () => const LoginPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.dueFeesLoginPermission,
      page: () => const DueFeesLoginPermissionView(),
      binding: AccessControlBinding(),
    ),
    // Additional routes will be added module by module
  ];
}
