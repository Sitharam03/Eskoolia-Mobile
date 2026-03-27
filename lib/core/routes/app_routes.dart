/// Named route string constants for GetX navigation.
abstract class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // Access Control
  static const String roles = '/roles';
  static const String assignPermissionRoot = '/roles/assign-permission';
  static const String assignPermission = '/roles/assign-permission/:id';
  static const String loginPermission = '/roles/login-permission';
  static const String dueFeesLoginPermission = '/roles/due-fees-login-permission';

  // Fees
  static const String feesGroups = '/fees/groups';
  static const String feesTypes = '/fees/types';
  static const String feesMaster = '/fees/master';
  static const String feesPayments = '/fees/payments';
  static const String feesDue = '/fees/due';
  static const String feesCarryForward = '/fees/carry-forward';

  // Academics
  static const String academics = '/academics';

  // Attendance
  static const String studentAttendance = '/attendance/students';
  static const String subjectAttendance = '/attendance/subjects';

  // Admissions
  static const String admissions = '/admissions';

  // Exams
  static const String exams = '/exams';

  // Students
  static const String students = '/students';
  static const String studentCategory = '/students/category';
  static const String studentGroup = '/students/group';
  static const String studentAdd = '/students/add';
  static const String studentList = '/students/list';
  static const String studentMultiClass = '/students/multi-class';
  static const String studentPromote = '/students/promote';
  static const String studentDisabled = '/students/disabled';
  static const String studentUnassigned = '/students/unassigned';
  static const String studentDeleteRecord = '/students/delete-record';
  static const String studentExport = '/students/export';

  // HR / Finance / Administration / Behaviour / Library
  static const String hr = '/hr';
  static const String finance = '/finance';
  static const String administration = '/administration';
  static const String behaviour = '/behaviour';
  static const String library = '/library';

  // Administration sub-routes
  static const String adminVisitorBook = '/administration/visitor-book';
  static const String adminComplaint = '/administration/complaint';
  static const String adminPhoneCallLog = '/administration/phone-call-log';
  static const String adminPostalDispatch = '/administration/postal-dispatch';
  static const String adminPostalReceive = '/administration/postal-receive';
  static const String adminSetup = '/administration/admin-setup';
  static const String adminAdmissionQuery = '/administration/admission-query';
  static const String adminIdCard = '/administration/id-card';
  static const String adminCertificate = '/administration/certificate';
  static const String adminGenerateIdCard = '/administration/generate-id-card';
  static const String adminGenerateCertificate = '/administration/generate-certificate';
}
