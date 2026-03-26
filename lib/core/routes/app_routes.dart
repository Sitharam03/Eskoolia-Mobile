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

  // HR / Finance / Administration / Behaviour / Library
  static const String hr = '/hr';
  static const String finance = '/finance';
  static const String administration = '/administration';
  static const String behaviour = '/behaviour';
  static const String library = '/library';
}
