import 'package:get/get.dart';
import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/access_control/bindings/access_control_binding.dart';
import '../../features/access_control/views/roles_view.dart';
import '../../features/access_control/views/assign_permission_view.dart';
import '../../features/access_control/views/login_permission_view.dart';
import '../../features/access_control/views/due_fees_login_permission_view.dart';
import '../../features/administration/bindings/administration_binding.dart';
import '../../features/administration/views/visitor_book_view.dart';
import '../../features/administration/views/complaint_view.dart';
import '../../features/administration/views/phone_call_log_view.dart';
import '../../features/administration/views/postal_dispatch_view.dart';
import '../../features/administration/views/postal_receive_view.dart';
import '../../features/administration/views/admin_setup_view.dart';
import '../../features/administration/views/admission_query_view.dart';
import '../../features/administration/views/id_card_view.dart';
import '../../features/administration/views/certificate_view.dart';
import '../../features/administration/views/generate_id_card_view.dart';
import '../../features/administration/views/generate_certificate_view.dart';
import '../../features/students/bindings/students_binding.dart';
import '../../features/students/views/student_category_view.dart';
import '../../features/students/views/student_group_view.dart';
import '../../features/students/views/student_add_view.dart';
import '../../features/students/views/student_list_view.dart';
import '../../features/students/views/student_multi_class_view.dart';
import '../../features/students/views/student_promote_view.dart';
import '../../features/students/views/student_disabled_view.dart';
import '../../features/students/views/student_unassigned_view.dart';
import '../../features/students/views/student_delete_record_view.dart';
import '../../features/students/views/student_export_view.dart';
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
    // Administration
    GetPage(name: AppRoutes.adminVisitorBook, page: () => const VisitorBookView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminComplaint, page: () => const ComplaintView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPhoneCallLog, page: () => const PhoneCallLogView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPostalDispatch, page: () => const PostalDispatchView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPostalReceive, page: () => const PostalReceiveView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminSetup, page: () => const AdminSetupView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminAdmissionQuery, page: () => const AdmissionQueryView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminIdCard, page: () => const IdCardView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminCertificate, page: () => const CertificateView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminGenerateIdCard, page: () => const GenerateIdCardView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminGenerateCertificate, page: () => const GenerateCertificateView(), binding: AdministrationBinding()),
    // ── Students ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.studentCategory,
      page: () => const StudentCategoryView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentGroup,
      page: () => const StudentGroupView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentAdd,
      page: () => const StudentAddView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentList,
      page: () => const StudentListView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentMultiClass,
      page: () => const StudentMultiClassView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentPromote,
      page: () => const StudentPromoteView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDisabled,
      page: () => const StudentDisabledView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentUnassigned,
      page: () => const StudentUnassignedView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDeleteRecord,
      page: () => const StudentDeleteRecordView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentExport,
      page: () => const StudentExportView(),
      binding: StudentsBinding(),
    ),
    // Additional routes will be added module by module
  ];
}
