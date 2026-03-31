class SidebarItem {
  final String id;
  final String name;
  final String? route;
  final List<SidebarItem>? children;
  final int? iconCodePoint;

  const SidebarItem({
    required this.id,
    required this.name,
    this.route,
    this.children,
    this.iconCodePoint,
  });
}

class MenuData {
  static const List<SidebarItem> items = [
    SidebarItem(
      id: "dashboard",
      name: "Dashboard",
      route: "/dashboard",
      iconCodePoint: 0xe1b1, // Icons.dashboard
    ),
    SidebarItem(
      id: "role-permission",
      name: "Role Permission",
      iconCodePoint: 0xe582, // Icons.security
      children: [
        SidebarItem(id: "roles", name: "Role", route: "/roles"),
        SidebarItem(
            id: "assign-permission",
            name: "Assign Permission",
            route: "/roles/assign-permission"),
        SidebarItem(
            id: "login-permission",
            name: "Login Permission",
            route: "/roles/login-permission"),
        SidebarItem(
            id: "due-fees-login-permission",
            name: "Due Fees Login Permission",
            route: "/roles/due-fees-login-permission"),
      ],
    ),
    SidebarItem(
      id: "administration",
      name: "Admin Section",
      iconCodePoint: 0xe056, // Icons.admin_panel_settings
      children: [
        SidebarItem(
            id: "admission-query",
            name: "Admission Query",
            route: "/administration/admission-query"),
        SidebarItem(
            id: "visitor-book",
            name: "Visitor Book",
            route: "/administration/visitor-book"),
        SidebarItem(
            id: "complaint", name: "Complaint", route: "/administration/complaint"),
        SidebarItem(
            id: "postal-receive",
            name: "Postal Receive",
            route: "/administration/postal-receive"),
        SidebarItem(
            id: "postal-dispatch",
            name: "Postal Dispatch",
            route: "/administration/postal-dispatch"),
        SidebarItem(
            id: "phone-call-log",
            name: "Phone Call Log",
            route: "/administration/phone-call-log"),
        SidebarItem(
            id: "admin-setup",
            name: "Admin Setup",
            route: "/administration/admin-setup"),
        SidebarItem(id: "id-card", name: "ID Card", route: "/administration/id-card"),
        SidebarItem(
            id: "certificate",
            name: "Certificate",
            route: "/administration/certificate"),
        SidebarItem(
            id: "generate-certificate",
            name: "Generate Certificate",
            route: "/administration/generate-certificate"),
        SidebarItem(
            id: "generate-id-card",
            name: "Generate ID Card",
            route: "/administration/generate-id-card"),
      ],
    ),
    SidebarItem(
      id: "student-info",
      name: "Student Info",
      iconCodePoint: 0xe242, // Icons.face
      children: [
        SidebarItem(
            id: "student-category",
            name: "Student Category",
            route: "/students/category"),
        SidebarItem(id: "add-student", name: "Add Student", route: "/students/add"),
        SidebarItem(
            id: "student-list", name: "Student List", route: "/students/list"),
        SidebarItem(
            id: "multi-class-student",
            name: "Multi Class Student",
            route: "/students/multi-class"),
        SidebarItem(
            id: "delete-student-record",
            name: "Delete Student Record",
            route: "/students/delete-record"),
        SidebarItem(
            id: "unassigned-student",
            name: "Unassigned Student",
            route: "/students/unassigned"),
        SidebarItem(
            id: "student-attendance",
            name: "Student Attendance",
            route: "/attendance/student"),
        SidebarItem(
            id: "student-attendance-import",
            name: "Student Attendance Import",
            route: "/attendance/student/import"),
        SidebarItem(
            id: "student-group", name: "Student Group", route: "/students/group"),
        SidebarItem(
            id: "student-promote",
            name: "Student Promote",
            route: "/students/promote"),
        SidebarItem(
            id: "disabled-students",
            name: "Disabled Students",
            route: "/students/disabled"),
        SidebarItem(
            id: "subject-wise-attendance",
            name: "Subject Wise Attendance",
            route: "/attendance/subject"),
        SidebarItem(
            id: "subject-wise-attendance-report",
            name: "Subject Wise Attendance Report",
            route: "/attendance/subject-report"),
        SidebarItem(
            id: "student-export", name: "Student Export", route: "/students/export"),
        SidebarItem(
            id: "sms-sending-time",
            name: "SMS Sending Time",
            route: "/students/sms-sending-time"),
      ],
    ),
    SidebarItem(
      id: "academics",
      name: "Academics",
      iconCodePoint: 0xe80c, // Icons.school
      children: [
        SidebarItem(
            id: "core-setup", name: "Core Setup", route: "/academics/core-setup"),
        SidebarItem(
            id: "assign-class-teacher",
            name: "Assign Class Teacher",
            route: "/academics/assign-class-teacher"),
        SidebarItem(
            id: "assign-subject",
            name: "Assign Subject",
            route: "/academics/assign-subject"),
        SidebarItem(
            id: "class-room", name: "Class Room", route: "/academics/class-room"),
        SidebarItem(
            id: "class-routine",
            name: "Class Routine",
            route: "/academics/class-routine"),
        SidebarItem(id: "lessons", name: "Lesson", route: "/academics/lessons"),
        SidebarItem(id: "topics", name: "Topic", route: "/academics/topics"),
        SidebarItem(
            id: "lesson-planner",
            name: "Lesson Planner",
            route: "/academics/lesson-planner"),
        SidebarItem(
            id: "add-homework",
            name: "Add Homework",
            route: "/academics/homework/add"),
        SidebarItem(
            id: "homework-list",
            name: "Homework List",
            route: "/academics/homework/list"),
        SidebarItem(
            id: "homework-report",
            name: "Homework Evaluation Report",
            route: "/academics/homework/eval-report"),
        SidebarItem(
            id: "upload-content",
            name: "Upload Content",
            route: "/academics/upload-content"),
        SidebarItem(
            id: "assignment-list",
            name: "Assignment List",
            route: "/academics/assignments"),
        SidebarItem(
            id: "study-material-list",
            name: "Study Material List",
            route: "/academics/study-material"),
        SidebarItem(
            id: "syllabus-list",
            name: "Syllabus List",
            route: "/academics/syllabus"),
        SidebarItem(
            id: "other-downloads-list",
            name: "Other Downloads List",
            route: "/academics/other-downloads"),
      ],
    ),
    SidebarItem(
      id: "examination",
      name: "Examination",
      iconCodePoint: 0xe06d, // Icons.assignment
      children: [
        SidebarItem(id: "exam-type", name: "Exam Type", route: "/exams/exam-type"),
        SidebarItem(id: "exam-setup", name: "Exam Setup", route: "/exams/setup"),
        SidebarItem(
            id: "exam-schedule", name: "Exam Schedule", route: "/exams/schedule"),
        SidebarItem(
            id: "exam-schedule-report",
            name: "Exam Schedule Report",
            route: "/exams/schedule-report"),
        SidebarItem(
            id: "exam-attendance",
            name: "Exam Attendance",
            route: "/exams/attendance"),
        SidebarItem(
            id: "exam-attendance-report",
            name: "Exam Attendance Report",
            route: "/exams/attendance-report"),
        SidebarItem(
            id: "marks-register",
            name: "Marks Register",
            route: "/exams/marks-register"),
        SidebarItem(
            id: "add-marks",
            name: "Add Marks",
            route: "/exams/marks-register-create"),
        SidebarItem(
            id: "result-publish",
            name: "Result Publish",
            route: "/exams/result-publish"),
        SidebarItem(
            id: "student-mark-sheet",
            name: "Student Mark Sheet",
            route: "/exams/student-report"),
        SidebarItem(
            id: "merit-list", name: "Merit List", route: "/exams/merit-report"),
        SidebarItem(
            id: "online-exam", name: "Online Exam", route: "/exams/online-exam"),
        SidebarItem(
            id: "admit-card",
            name: "Admit Card",
            route: "/exams/exam-plan/admit-card"),
        SidebarItem(
            id: "seat-plan", name: "Seat Plan", route: "/exams/exam-plan/seat-plan"),
      ],
    ),
    SidebarItem(
      id: "fees",
      name: "Fees",
      iconCodePoint: 0xe05e, // Icons.attach_money
      children: [
        SidebarItem(id: "fees-group", name: "Fees Group", route: "/fees/groups"),
        SidebarItem(id: "fees-type", name: "Fees Type", route: "/fees/types"),
        SidebarItem(id: "fees-master", name: "Fees Master", route: "/fees/master"),
        SidebarItem(
            id: "fees-collection",
            name: "Fees Collection",
            route: "/fees/payments"),
        SidebarItem(id: "fees-due", name: "Fees Due", route: "/fees/due"),
        SidebarItem(
            id: "fees-carry-forward",
            name: "Fees Carry Forward",
            route: "/fees/carry-forward"),
      ],
    ),
    SidebarItem(
      id: "library",
      name: "Library",
      iconCodePoint: 0xe3e4, // Icons.local_library
      children: [
        SidebarItem(
            id: "book-categories",
            name: "Book Categories",
            route: "/library/categories"),
        SidebarItem(id: "books", name: "Books", route: "/library/books"),
        SidebarItem(
            id: "library-members",
            name: "Library Members",
            route: "/library/members"),
        SidebarItem(
            id: "book-issues", name: "Book Issues", route: "/library/issues"),
      ],
    ),
    SidebarItem(
      id: "behaviour-records",
      name: "Behaviour Records",
      iconCodePoint: 0xe8e8, // Icons.psychology
      children: [
        SidebarItem(
            id: "behaviour-assign-incident",
            name: "Assign Incident",
            route: "/behaviour/assign-incident"),
        SidebarItem(
            id: "behaviour-incident",
            name: "Incident",
            route: "/behaviour/incidents"),
        SidebarItem(
            id: "behaviour-student-incident-report",
            name: "Student Incident Report",
            route: "/behaviour/reports/student-incident"),
        SidebarItem(
            id: "behaviour-student-rank-report",
            name: "Student Behaviour Rank Report",
            route: "/behaviour/reports/student-rank"),
        SidebarItem(
            id: "behaviour-class-section-rank-report",
            name: "Class Section Wise Rank Report",
            route: "/behaviour/reports/class-section-rank"),
        SidebarItem(
            id: "behaviour-incident-wise-report",
            name: "Incident Wise Report",
            route: "/behaviour/reports/incident-wise"),
        SidebarItem(
            id: "behaviour-setting",
            name: "Behaviour Record Setting",
            route: "/behaviour/settings"),
      ],
    ),
    SidebarItem(
      id: "human-resource",
      name: "Human Resource",
      iconCodePoint: 0xe464, // Icons.people_alt
      children: [
        SidebarItem(
            id: "hr-departments", name: "HR Departments", route: "/hr/departments"),
        SidebarItem(
            id: "hr-designations",
            name: "HR Designations",
            route: "/hr/designations"),
        SidebarItem(id: "hr-staff", name: "Add Staff", route: "/hr/staff"),
        SidebarItem(
            id: "hr-staff-directory",
            name: "Staff Directory",
            route: "/hr/staff-directory"),
        SidebarItem(
            id: "hr-leave-types", name: "HR Leave Types", route: "/hr/leave-types"),
        SidebarItem(
            id: "hr-leave-defines",
            name: "HR Leave Define",
            route: "/hr/leave-defines"),
        SidebarItem(
            id: "hr-leave-requests",
            name: "HR Leave Requests",
            route: "/hr/leave-requests"),
        SidebarItem(
            id: "hr-staff-attendance",
            name: "HR Staff Attendance",
            route: "/hr/staff-attendance"),
        SidebarItem(id: "hr-payroll", name: "HR Payroll", route: "/hr/payroll"),
      ],
    ),
    SidebarItem(
      id: "finance",
      name: "Accounts",
      iconCodePoint: 0xe065, // Icons.account_balance
      children: [
        SidebarItem(
            id: "chart-of-accounts",
            name: "Chart Of Accounts",
            route: "/finance/chart-of-accounts"),
        SidebarItem(
            id: "bank-accounts", name: "Bank Accounts", route: "/finance/bank-accounts"),
        SidebarItem(
            id: "ledger-entries", name: "Ledger Entries", route: "/finance/ledger"),
        SidebarItem(
            id: "fund-transfer", name: "Fund Transfer", route: "/finance/fund-transfer"),
      ],
    ),
    SidebarItem(
      id: "settings",
      name: "Settings Section",
      iconCodePoint: 0xe5ce, // Icons.settings
      children: [
        SidebarItem(id: "general-settings", name: "General Settings", route: "/setup"),
        SidebarItem(
            id: "class-periods", name: "Class Periods", route: "/setup/class-periods"),
      ],
    ),
  ];
}
