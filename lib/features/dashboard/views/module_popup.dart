import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';

// ── Data Classes ───────────────────────────────────────────────────────────────

class DashboardSubItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const DashboardSubItem(
      this.title, this.subtitle, this.icon, this.color, this.route);
}

class DashboardModule {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final List<DashboardSubItem> items;

  const DashboardModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.items,
  });
}

// ── Module Data (12 modules — Attendance merged into Student Info) ────────────

const kDashboardModules = <DashboardModule>[
  // ── STUDENT INFO ─────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Student Info',
    description: 'Student management & records',
    icon: Icons.face_rounded,
    gradient: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
    iconColor: Color(0xFF6366F1),
    items: [
      DashboardSubItem('Student List', 'View all students', Icons.list_alt_rounded, Color(0xFF6366F1), AppRoutes.studentList),
      DashboardSubItem('Add Student', 'Enroll new student', Icons.person_add_rounded, Color(0xFF8B5CF6), AppRoutes.studentAdd),
      DashboardSubItem('Categories', 'Student categories', Icons.category_rounded, Color(0xFF6366F1), AppRoutes.studentCategory),
      DashboardSubItem('Groups', 'Student groups', Icons.group_rounded, Color(0xFF8B5CF6), AppRoutes.studentGroup),
      DashboardSubItem('Multi-Class', 'Multi-class students', Icons.class_rounded, Color(0xFF6366F1), AppRoutes.studentMultiClass),
      DashboardSubItem('Promote', 'Promote to next class', Icons.arrow_upward_rounded, Color(0xFF8B5CF6), AppRoutes.studentPromote),
      DashboardSubItem('Disabled Students', 'View disabled students', Icons.person_off_rounded, Color(0xFF6366F1), AppRoutes.studentDisabled),
      DashboardSubItem('Unassigned', 'Unassigned students', Icons.manage_accounts_rounded, Color(0xFF8B5CF6), AppRoutes.studentUnassigned),
      DashboardSubItem('Delete Record', 'Remove student record', Icons.delete_sweep_rounded, Color(0xFF6366F1), AppRoutes.studentDeleteRecord),
      DashboardSubItem('Export', 'Export student data', Icons.file_download_rounded, Color(0xFF8B5CF6), AppRoutes.studentExport),
      DashboardSubItem('SMS Alerts', 'Messaging settings', Icons.sms_rounded, Color(0xFF6366F1), AppRoutes.studentSms),
      // Attendance (part of Student Info module)
      DashboardSubItem('Mark Attendance', 'Daily class attendance', Icons.fact_check_rounded, Color(0xFFEF4444), AppRoutes.studentAttendance),
      DashboardSubItem('Subject Attendance', 'Subject-wise records', Icons.subject_rounded, Color(0xFFDC2626), AppRoutes.subjectAttendance),
      DashboardSubItem('Attendance Report', 'Subject-wise report', Icons.bar_chart_rounded, Color(0xFFEF4444), AppRoutes.studentSubjectWiseAttendanceReport),
      DashboardSubItem('Import Attendance', 'Bulk import', Icons.upload_rounded, Color(0xFFDC2626), AppRoutes.studentAttendanceImport),
      DashboardSubItem('Subject-wise View', 'View by subject', Icons.table_chart_rounded, Color(0xFFEF4444), AppRoutes.studentSubjectWiseAttendance),
    ],
  ),

  // ── ACADEMICS ────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Academics',
    description: 'Curriculum & class management',
    icon: Icons.school_rounded,
    gradient: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    iconColor: Color(0xFF22C55E),
    items: [
      DashboardSubItem('Core Setup', 'Classes & subjects', Icons.tune_rounded, Color(0xFF22C55E), AppRoutes.academicsCoreSetup),
      DashboardSubItem('Assign Teacher', 'Class teacher assignment', Icons.assignment_ind_rounded, Color(0xFF16A34A), AppRoutes.academicsAssignClassTeacher),
      DashboardSubItem('Assign Subject', 'Subject assignments', Icons.subject_rounded, Color(0xFF22C55E), AppRoutes.academicsAssignSubject),
      DashboardSubItem('Classroom', 'Classroom management', Icons.meeting_room_rounded, Color(0xFF16A34A), AppRoutes.academicsClassRoom),
      DashboardSubItem('Class Routine', 'Timetable schedule', Icons.schedule_rounded, Color(0xFF22C55E), AppRoutes.academicsClassRoutine),
      DashboardSubItem('Lessons', 'Lesson management', Icons.book_rounded, Color(0xFF16A34A), AppRoutes.academicsLessons),
      DashboardSubItem('Topics', 'Topic management', Icons.topic_rounded, Color(0xFF22C55E), AppRoutes.academicsTopics),
      DashboardSubItem('Lesson Planner', 'Plan lessons', Icons.auto_stories_rounded, Color(0xFF16A34A), AppRoutes.academicsLessonPlanner),
      DashboardSubItem('Add Homework', 'Create homework', Icons.post_add_rounded, Color(0xFF22C55E), AppRoutes.academicsHomeworkAdd),
      DashboardSubItem('Homework List', 'All homework', Icons.assignment_rounded, Color(0xFF16A34A), AppRoutes.academicsHomeworkList),
      DashboardSubItem('Homework Report', 'Evaluation report', Icons.rate_review_rounded, Color(0xFF22C55E), AppRoutes.academicsHomeworkEvalReport),
      DashboardSubItem('Upload Content', 'Upload study files', Icons.upload_rounded, Color(0xFF16A34A), AppRoutes.academicsUploadContent),
      DashboardSubItem('Assignments', 'Assignment list', Icons.task_rounded, Color(0xFF22C55E), AppRoutes.academicsAssignmentList),
      DashboardSubItem('Study Material', 'View study material', Icons.folder_rounded, Color(0xFF16A34A), AppRoutes.academicsStudyMaterialList),
      DashboardSubItem('Syllabus', 'Syllabus list', Icons.list_alt_rounded, Color(0xFF22C55E), AppRoutes.academicsSyllabusList),
      DashboardSubItem('Other Downloads', 'Downloadable content', Icons.download_rounded, Color(0xFF16A34A), AppRoutes.academicsOtherDownloadsList),
    ],
  ),

  // ── EXAMINATION ──────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Examination',
    description: 'Exams, marks & results',
    icon: Icons.assignment_rounded,
    gradient: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    iconColor: Color(0xFFF97316),
    items: [
      DashboardSubItem('Exam Type', 'Define exam types', Icons.category_rounded, Color(0xFFF97316), AppRoutes.examType),
      DashboardSubItem('Exam Setup', 'Configure exams', Icons.tune_rounded, Color(0xFFEA580C), AppRoutes.examSetup),
      DashboardSubItem('Schedule', 'Exam timetable', Icons.calendar_month_rounded, Color(0xFFF97316), AppRoutes.examSchedule),
      DashboardSubItem('Schedule Report', 'Timetable report', Icons.calendar_today_rounded, Color(0xFFEA580C), AppRoutes.examScheduleReport),
      DashboardSubItem('Add Marks', 'Create marks entry', Icons.edit_rounded, Color(0xFFF97316), AppRoutes.examMarksCreate),
      DashboardSubItem('Marks Register', 'View marks register', Icons.rate_review_rounded, Color(0xFFEA580C), AppRoutes.examMarksRegister),
      DashboardSubItem('Exam Attendance', 'Mark exam attendance', Icons.fact_check_rounded, Color(0xFFF97316), AppRoutes.examAttendanceCreate),
      DashboardSubItem('Attendance Report', 'Exam attendance report', Icons.bar_chart_rounded, Color(0xFFEA580C), AppRoutes.examAttendanceReport),
      DashboardSubItem('Result Publish', 'Publish results', Icons.publish_rounded, Color(0xFFF97316), AppRoutes.examResultPublish),
      DashboardSubItem('Student Report', 'Mark sheet', Icons.description_rounded, Color(0xFFEA580C), AppRoutes.examStudentReport),
      DashboardSubItem('Merit Report', 'Merit list', Icons.emoji_events_rounded, Color(0xFFF97316), AppRoutes.examMeritReport),
      DashboardSubItem('Admit Card', 'Generate admit cards', Icons.credit_card_rounded, Color(0xFFEA580C), AppRoutes.examAdmitCard),
      DashboardSubItem('Seat Plan', 'Exam seat plan', Icons.event_seat_rounded, Color(0xFFF97316), AppRoutes.examSeatPlan),
      DashboardSubItem('Online Exam', 'Online examination', Icons.quiz_rounded, Color(0xFFEA580C), AppRoutes.onlineExam),
    ],
  ),

  // ── FEES ─────────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Fees',
    description: 'Fee collection & tracking',
    icon: Icons.payments_rounded,
    gradient: [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
    iconColor: Color(0xFF14B8A6),
    items: [
      DashboardSubItem('Collect Fees', 'Payment collection', Icons.payments_rounded, Color(0xFF14B8A6), AppRoutes.feesPayments),
      DashboardSubItem('Due Fees', 'Pending payments', Icons.receipt_long_rounded, Color(0xFF0D9488), AppRoutes.feesDue),
      DashboardSubItem('Fees Master', 'Fee structure', Icons.dashboard_rounded, Color(0xFF14B8A6), AppRoutes.feesMaster),
      DashboardSubItem('Fees Groups', 'Group management', Icons.groups_rounded, Color(0xFF0D9488), AppRoutes.feesGroups),
      DashboardSubItem('Fees Types', 'Fee categories', Icons.category_rounded, Color(0xFF14B8A6), AppRoutes.feesTypes),
      DashboardSubItem('Carry Forward', 'Roll-over dues', Icons.redo_rounded, Color(0xFF0D9488), AppRoutes.feesCarryForward),
    ],
  ),

  // ── HUMAN RESOURCE ───────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Human Resource',
    description: 'Staff & payroll management',
    icon: Icons.people_alt_rounded,
    gradient: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    iconColor: Color(0xFF0EA5E9),
    items: [
      DashboardSubItem('Staff', 'Add & manage staff', Icons.badge_rounded, Color(0xFF0EA5E9), AppRoutes.hrStaff),
      DashboardSubItem('Staff Directory', 'Staff directory', Icons.contacts_rounded, Color(0xFF0284C7), AppRoutes.hrStaffDirectory),
      DashboardSubItem('Departments', 'Dept. management', Icons.account_tree_rounded, Color(0xFF0EA5E9), AppRoutes.hrDepartments),
      DashboardSubItem('Designations', 'Job designations', Icons.work_rounded, Color(0xFF0284C7), AppRoutes.hrDesignations),
      DashboardSubItem('Leave Types', 'Define leave types', Icons.event_available_rounded, Color(0xFF0EA5E9), AppRoutes.hrLeaveTypes),
      DashboardSubItem('Leave Defines', 'Leave allocations', Icons.rule_rounded, Color(0xFF0284C7), AppRoutes.hrLeaveDefines),
      DashboardSubItem('Leave Requests', 'Approve/reject leaves', Icons.event_rounded, Color(0xFF0EA5E9), AppRoutes.hrLeaveRequests),
      DashboardSubItem('Staff Attendance', 'Staff daily attendance', Icons.schedule_rounded, Color(0xFF0284C7), AppRoutes.hrStaffAttendance),
      DashboardSubItem('Payroll', 'Salary management', Icons.account_balance_wallet_rounded, Color(0xFF0EA5E9), AppRoutes.hrPayroll),
    ],
  ),

  // ── ACCOUNTS ─────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Accounts',
    description: 'Finance & accounting records',
    icon: Icons.account_balance_rounded,
    gradient: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
    iconColor: Color(0xFF10B981),
    items: [
      DashboardSubItem('Chart of Accounts', 'Account hierarchy', Icons.account_tree_rounded, Color(0xFF10B981), AppRoutes.financeChartOfAccounts),
      DashboardSubItem('Bank Accounts', 'Bank management', Icons.account_balance_rounded, Color(0xFF059669), AppRoutes.financeBankAccounts),
      DashboardSubItem('Ledger Entries', 'Journal entries', Icons.receipt_rounded, Color(0xFF10B981), AppRoutes.financeLedger),
      DashboardSubItem('Fund Transfer', 'Transfer between banks', Icons.swap_horiz_rounded, Color(0xFF059669), AppRoutes.financeFundTransfer),
    ],
  ),

  // ── BEHAVIOUR ────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Behaviour',
    description: 'Student behaviour records',
    icon: Icons.psychology_rounded,
    gradient: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    iconColor: Color(0xFFF59E0B),
    items: [
      DashboardSubItem('Incidents', 'Define incidents', Icons.report_rounded, Color(0xFFF59E0B), AppRoutes.behaviourIncidents),
      DashboardSubItem('Assign Incident', 'Assign to students', Icons.assignment_ind_rounded, Color(0xFFD97706), AppRoutes.behaviourAssignIncident),
      DashboardSubItem('Student Report', 'Student incident history', Icons.person_search_rounded, Color(0xFFF59E0B), AppRoutes.behaviourStudentIncidentReport),
      DashboardSubItem('Student Rank', 'Behaviour ranking', Icons.leaderboard_rounded, Color(0xFFD97706), AppRoutes.behaviourStudentRankReport),
      DashboardSubItem('Class-Section Rank', 'Class-wise rank report', Icons.school_rounded, Color(0xFFF59E0B), AppRoutes.behaviourClassSectionRankReport),
      DashboardSubItem('Incident-wise', 'Incident wise report', Icons.analytics_rounded, Color(0xFFD97706), AppRoutes.behaviourIncidentWiseReport),
      DashboardSubItem('Settings', 'Behaviour configuration', Icons.settings_rounded, Color(0xFFF59E0B), AppRoutes.behaviourSettings),
    ],
  ),

  // ── ADMINISTRATION ───────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Administration',
    description: 'Office & admin operations',
    icon: Icons.admin_panel_settings_rounded,
    gradient: [Color(0xFFFDF4FF), Color(0xFFF3E8FF)],
    iconColor: Color(0xFFA855F7),
    items: [
      DashboardSubItem('Visitor Book', 'Visitor log', Icons.book_rounded, Color(0xFFA855F7), AppRoutes.adminVisitorBook),
      DashboardSubItem('Complaints', 'Complaint register', Icons.feedback_rounded, Color(0xFF9333EA), AppRoutes.adminComplaint),
      DashboardSubItem('Phone Call Log', 'Call log records', Icons.phone_rounded, Color(0xFFA855F7), AppRoutes.adminPhoneCallLog),
      DashboardSubItem('Postal Receive', 'Received mail log', Icons.mail_rounded, Color(0xFF9333EA), AppRoutes.adminPostalReceive),
      DashboardSubItem('Postal Dispatch', 'Dispatched mail log', Icons.send_rounded, Color(0xFFA855F7), AppRoutes.adminPostalDispatch),
      DashboardSubItem('Admission Query', 'New admission queries', Icons.person_add_rounded, Color(0xFF9333EA), AppRoutes.adminAdmissionQuery),
      DashboardSubItem('Admin Setup', 'Admin configuration', Icons.settings_rounded, Color(0xFFA855F7), AppRoutes.adminSetup),
      DashboardSubItem('ID Card', 'ID card setup', Icons.badge_rounded, Color(0xFF9333EA), AppRoutes.adminIdCard),
      DashboardSubItem('Generate ID Card', 'Print ID cards', Icons.print_rounded, Color(0xFFA855F7), AppRoutes.adminGenerateIdCard),
      DashboardSubItem('Certificate', 'Certificate setup', Icons.verified_rounded, Color(0xFF9333EA), AppRoutes.adminCertificate),
      DashboardSubItem('Generate Certificate', 'Print certificates', Icons.workspace_premium_rounded, Color(0xFFA855F7), AppRoutes.adminGenerateCertificate),
    ],
  ),

  // ── ROLE & PERMISSION ────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Role & Permission',
    description: 'Access control & user roles',
    icon: Icons.shield_rounded,
    gradient: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
    iconColor: Color(0xFF6D28D9),
    items: [
      DashboardSubItem('Roles', 'Create & manage roles', Icons.security_rounded, Color(0xFF6D28D9), AppRoutes.roles),
      DashboardSubItem('Assign Permission', 'Map permissions to roles', Icons.lock_open_rounded, Color(0xFF7C3AED), AppRoutes.assignPermissionRoot),
      DashboardSubItem('Login Permission', 'Portal login access control', Icons.login_rounded, Color(0xFF6D28D9), AppRoutes.loginPermission),
      DashboardSubItem('Due Fees Login', 'Login restriction by fee status', Icons.payments_rounded, Color(0xFF7C3AED), AppRoutes.dueFeesLoginPermission),
    ],
  ),

  // ── LIBRARY ──────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Library',
    description: 'Books & library management',
    icon: Icons.local_library_rounded,
    gradient: [Color(0xFFF0F9FF), Color(0xFFDBEAFE)],
    iconColor: Color(0xFF3B82F6),
    items: [
      DashboardSubItem('Books', 'Manage book catalog', Icons.menu_book_rounded, Color(0xFF3B82F6), AppRoutes.libraryBooks),
      DashboardSubItem('Book Issues', 'Issue & return books', Icons.bookmark_rounded, Color(0xFF2563EB), AppRoutes.libraryIssues),
      DashboardSubItem('Members', 'Library members', Icons.people_rounded, Color(0xFF3B82F6), AppRoutes.libraryMembers),
      DashboardSubItem('Categories', 'Book categories', Icons.category_rounded, Color(0xFF2563EB), AppRoutes.libraryCategories),
    ],
  ),

  // ── TRANSPORT ────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Transport',
    description: 'Fleet & student transport',
    icon: Icons.directions_bus_rounded,
    gradient: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    iconColor: Color(0xFFEA580C),
    items: [
      DashboardSubItem('Vehicles', 'Fleet management', Icons.directions_bus_rounded, Color(0xFFEA580C), AppRoutes.transportVehicles),
      DashboardSubItem('Routes', 'Route planning', Icons.route_rounded, Color(0xFFC2410C), AppRoutes.transportRoutes),
      DashboardSubItem('Assign Vehicles', 'Assign to routes', Icons.assignment_rounded, Color(0xFFEA580C), AppRoutes.transportAssignVehicles),
      DashboardSubItem('Student Report', 'Transport report', Icons.description_rounded, Color(0xFFC2410C), AppRoutes.transportStudentReport),
    ],
  ),

  // ── INVENTORY ────────────────────────────────────────────────────────────────
  DashboardModule(
    title: 'Inventory',
    description: 'Stock & supply management',
    icon: Icons.inventory_2_rounded,
    gradient: [Color(0xFFF7FEE7), Color(0xFFECFCCB)],
    iconColor: Color(0xFF84CC16),
    items: [
      DashboardSubItem('Item Categories', 'Category management', Icons.category_rounded, Color(0xFF84CC16), AppRoutes.inventoryCategories),
      DashboardSubItem('Stores', 'Store locations', Icons.store_rounded, Color(0xFF65A30D), AppRoutes.inventoryStores),
      DashboardSubItem('Suppliers', 'Vendor management', Icons.local_shipping_rounded, Color(0xFF84CC16), AppRoutes.inventorySuppliers),
      DashboardSubItem('Items', 'Item catalog', Icons.inventory_rounded, Color(0xFF65A30D), AppRoutes.inventoryItems),
      DashboardSubItem('Receive Items', 'Stock received', Icons.download_rounded, Color(0xFF84CC16), AppRoutes.inventoryReceive),
      DashboardSubItem('Issue Items', 'Items issued out', Icons.send_rounded, Color(0xFF65A30D), AppRoutes.inventoryIssue),
      DashboardSubItem('Sell Items', 'Items sold', Icons.local_offer_rounded, Color(0xFF84CC16), AppRoutes.inventorySell),
    ],
  ),
];

// ── Bottom Bar Special Modules ─────────────────────────────────────────────────
// These appear only in the bottom bar (Reports & Settings), not as dashboard cards.

const kReportsModule = DashboardModule(
  title: 'Reports',
  description: 'All module reports & analytics',
  icon: Icons.bar_chart_rounded,
  gradient: [Color(0xFFF0F9FF), Color(0xFFDBEAFE)],
  iconColor: Color(0xFF3B82F6),
  items: [
    // Examination reports
    DashboardSubItem('Student Mark Sheet', 'Individual exam results', Icons.description_rounded, Color(0xFFF97316), AppRoutes.examStudentReport),
    DashboardSubItem('Merit List', 'Class-wise merit list', Icons.emoji_events_rounded, Color(0xFFEA580C), AppRoutes.examMeritReport),
    DashboardSubItem('Exam Schedule', 'Schedule report', Icons.calendar_today_rounded, Color(0xFFF97316), AppRoutes.examScheduleReport),
    DashboardSubItem('Exam Attendance', 'Exam attendance report', Icons.fact_check_rounded, Color(0xFFEA580C), AppRoutes.examAttendanceReport),
    // Attendance reports
    DashboardSubItem('Attendance Report', 'Subject-wise attendance', Icons.bar_chart_rounded, Color(0xFFEF4444), AppRoutes.studentSubjectWiseAttendanceReport),
    // Academics reports
    DashboardSubItem('Homework Report', 'Homework evaluation', Icons.rate_review_rounded, Color(0xFF22C55E), AppRoutes.academicsHomeworkEvalReport),
    // Behaviour reports
    DashboardSubItem('Student Incidents', 'Student incident history', Icons.report_rounded, Color(0xFFF59E0B), AppRoutes.behaviourStudentIncidentReport),
    DashboardSubItem('Student Rank', 'Behaviour ranking', Icons.leaderboard_rounded, Color(0xFFD97706), AppRoutes.behaviourStudentRankReport),
    DashboardSubItem('Class-Section Rank', 'Class-wise rank report', Icons.school_rounded, Color(0xFFF59E0B), AppRoutes.behaviourClassSectionRankReport),
    DashboardSubItem('Incident-wise', 'Incident type analysis', Icons.analytics_rounded, Color(0xFFD97706), AppRoutes.behaviourIncidentWiseReport),
    // Transport report
    DashboardSubItem('Transport Report', 'Student transport details', Icons.directions_bus_rounded, Color(0xFFEA580C), AppRoutes.transportStudentReport),
  ],
);

const kSettingsModule = DashboardModule(
  title: 'Settings',
  description: 'Access control & system settings',
  icon: Icons.settings_rounded,
  gradient: [Color(0xFFFDF4FF), Color(0xFFF3E8FF)],
  iconColor: Color(0xFFA855F7),
  items: [
    // Access control
    DashboardSubItem('Roles', 'Define user roles', Icons.security_rounded, Color(0xFF6366F1), AppRoutes.roles),
    DashboardSubItem('Assign Permission', 'Map permissions to roles', Icons.lock_open_rounded, Color(0xFF8B5CF6), AppRoutes.assignPermissionRoot),
    DashboardSubItem('Login Permission', 'Portal access control', Icons.login_rounded, Color(0xFF6366F1), AppRoutes.loginPermission),
    DashboardSubItem('Due Fees Login', 'Conditional login by fees', Icons.payments_rounded, Color(0xFF8B5CF6), AppRoutes.dueFeesLoginPermission),
    // Admin settings
    DashboardSubItem('Admin Setup', 'System configuration', Icons.admin_panel_settings_rounded, Color(0xFFA855F7), AppRoutes.adminSetup),
  ],
);

// ── Popup Widget ───────────────────────────────────────────────────────────────

class ModulePopup {
  ModulePopup._();

  static void show(BuildContext context, DashboardModule module) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => _ModuleDialog(module: module),
    );
  }
}

class _ModuleDialog extends StatelessWidget {
  final DashboardModule module;
  const _ModuleDialog({required this.module});

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.78;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: SizedBox(
        height: maxH,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.08,
                  ),
                  itemCount: module.items.length,
                  itemBuilder: (_, i) => _SubCard(item: module.items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  module.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  module.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Color(0xFF6B7280), size: 22),
            onPressed: () => Navigator.pop(context),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _SubCard extends StatelessWidget {
  final DashboardSubItem item;
  const _SubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Get.toNamed(item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withValues(alpha: 0.22)),
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const Spacer(),
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF9CA3AF),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
