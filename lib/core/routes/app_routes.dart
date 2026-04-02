/// Named route string constants for GetX navigation.
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String chat = '/chat';

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
  static const String academicsCoreSetup = '/academics/core-setup';
  static const String academicsAssignClassTeacher = '/academics/assign-class-teacher';
  static const String academicsAssignSubject = '/academics/assign-subject';
  static const String academicsClassRoom = '/academics/class-room';
  static const String academicsClassRoutine = '/academics/class-routine';
  static const String academicsHomeworkAdd = '/academics/homework/add';
  static const String academicsHomeworkList = '/academics/homework/list';
  static const String academicsHomeworkEvalReport = '/academics/homework/eval-report';
  static const String academicsUploadContent = '/academics/upload-content';
  static const String academicsAssignmentList = '/academics/assignments';
  static const String academicsStudyMaterialList = '/academics/study-material';
  static const String academicsSyllabusList = '/academics/syllabus';
  static const String academicsOtherDownloadsList = '/academics/other-downloads';
  static const String academicsLessons = '/academics/lessons';
  static const String academicsTopics = '/academics/topics';
  static const String academicsLessonPlanner = '/academics/lesson-planner';

  // Attendance
  static const String studentAttendance = '/attendance/students';
  static const String studentAttendanceImport = '/attendance/student/import';
  static const String studentSubjectWiseAttendance = '/attendance/subject';
  static const String studentSubjectWiseAttendanceReport = '/attendance/subject-report';
  static const String subjectAttendance = '/attendance/subjects';

  // Admissions
  static const String admissions = '/admissions';

  // Exams
  static const String exams = '/exams';
  static const String examType = '/exams/exam-type';
  static const String examSetup = '/exams/setup';
  static const String examSchedule = '/exams/schedule';
  static const String examMarksCreate = '/exams/marks-register-create';
  static const String examMarksRegister = '/exams/marks-register';
  static const String examAdmitCard = '/exams/admit-card';
  static const String examSeatPlan = '/exams/seat-plan';
  static const String examAttendanceCreate = '/exams/attendance-create';
  static const String examAttendanceReport = '/exams/attendance-report';
  static const String examResultPublish = '/exams/result-publish';
  static const String examMeritReport = '/exams/merit-report';
  static const String examScheduleReport = '/exams/schedule-report';
  static const String examStudentReport = '/exams/student-report';
  static const String onlineExam = '/exams/online-exam';

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
  static const String studentSms = '/students/sms-sending-time';

  // Finance
  static const String financeChartOfAccounts = '/finance/chart-of-accounts';
  static const String financeBankAccounts = '/finance/bank-accounts';
  static const String financeLedger = '/finance/ledger';
  static const String financeFundTransfer = '/finance/fund-transfer';

  // HR / Administration / Behaviour
  static const String hr = '/hr';
  static const String hrDepartments = '/hr/departments';
  static const String hrDesignations = '/hr/designations';
  static const String hrStaff = '/hr/staff';
  static const String hrStaffDirectory = '/hr/staff-directory';
  static const String hrLeaveTypes = '/hr/leave-types';
  static const String hrLeaveDefines = '/hr/leave-defines';
  static const String hrLeaveRequests = '/hr/leave-requests';
  static const String hrStaffAttendance = '/hr/staff-attendance';
  static const String hrPayroll = '/hr/payroll';
  static const String finance = '/finance';
  static const String administration = '/administration';
  static const String behaviour = '/behaviour';

  // Behaviour sub-routes
  static const String behaviourIncidents = '/behaviour/incidents';
  static const String behaviourAssignIncident = '/behaviour/assign-incident';
  static const String behaviourStudentIncidentReport = '/behaviour/reports/student-incident';
  static const String behaviourStudentRankReport = '/behaviour/reports/student-rank';
  static const String behaviourClassSectionRankReport = '/behaviour/reports/class-section-rank';
  static const String behaviourIncidentWiseReport = '/behaviour/reports/incident-wise';
  static const String behaviourSettings = '/behaviour/settings';

  // Transport
  static const String transport = '/transport';
  static const String transportVehicles = '/transport/vehicles';
  static const String transportRoutes = '/transport/routes';
  static const String transportAssignVehicles = '/transport/assign-vehicles';
  static const String transportStudentReport = '/transport/student-report';

  // Inventory
  static const String inventory = '/inventory';
  static const String inventoryCategories = '/inventory/categories';
  static const String inventoryStores = '/inventory/stores';
  static const String inventorySuppliers = '/inventory/suppliers';
  static const String inventoryItems = '/inventory/items';
  static const String inventoryReceive = '/inventory/receive';
  static const String inventoryIssue = '/inventory/issue';
  static const String inventorySell = '/inventory/sell';

  // Library
  static const String library = '/library';
  static const String libraryCategories = '/library/categories';
  static const String libraryBooks = '/library/books';
  static const String libraryMembers = '/library/members';
  static const String libraryIssues = '/library/issues';

  // Communication
  static const String communication = '/communication';

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
