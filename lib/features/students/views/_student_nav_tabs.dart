import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';

/// Horizontal scrollable pill-chip tab bar for all Student Info views.
/// Matches the AdminNavTabs chip style used in the Administration module.
class StudentNavTabs extends StatefulWidget {
  final String activeRoute;
  const StudentNavTabs({super.key, required this.activeRoute});

  @override
  State<StudentNavTabs> createState() => _StudentNavTabsState();
}

class _StudentNavTabsState extends State<StudentNavTabs> {
  static const _tabs = [
    _TabItem(label: 'Student Categories', route: AppRoutes.studentCategory),
    _TabItem(label: 'Add Student', route: AppRoutes.studentAdd),
    _TabItem(label: 'Student List', route: AppRoutes.studentList),
    _TabItem(label: 'Multi-Class Student', route: AppRoutes.studentMultiClass),
    _TabItem(label: 'Delete Student Records', route: AppRoutes.studentDeleteRecord),
    _TabItem(label: 'Unassigned Student', route: AppRoutes.studentUnassigned),
    _TabItem(label: 'Student Attendance', route: AppRoutes.studentAttendance),
    _TabItem(label: 'Student Attendance Import', route: AppRoutes.studentAttendanceImport),
    _TabItem(label: 'Student Groups', route: AppRoutes.studentGroup),
    _TabItem(label: 'Student Promote', route: AppRoutes.studentPromote),
    _TabItem(label: 'Disabled Students', route: AppRoutes.studentDisabled),
    _TabItem(label: 'Subject Wise Attendance', route: AppRoutes.studentSubjectWiseAttendance),
    _TabItem(label: 'Subject Wise Attendance Report', route: AppRoutes.studentSubjectWiseAttendanceReport),
    _TabItem(label: 'Student Export', route: AppRoutes.studentExport),
    _TabItem(label: 'SMS Sending Time', route: AppRoutes.studentSms),
  ];

  final _scrollController = ScrollController();
  final _keys = List.generate(_tabs.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    // Jump instantly after layout — no animation so user never sees scroll-from-start
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final activeIndex = _tabs.indexWhere((t) => t.route == widget.activeRoute);
    if (activeIndex < 0) return;
    final ctx = _keys[activeIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: Duration.zero, // instant — no visible slide-from-start
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _NavChip(
                key: _keys[i],
                tab: _tabs[i],
                isActive: _tabs[i].route == widget.activeRoute,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  const _NavChip({super.key, required this.tab, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) Get.offNamed(tab.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tab.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final String route;
  const _TabItem({required this.label, required this.route});
}
