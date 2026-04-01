import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';

class ExamNavTabs extends StatefulWidget {
  final String activeRoute;
  const ExamNavTabs({super.key, required this.activeRoute});

  @override
  State<ExamNavTabs> createState() => _ExamNavTabsState();
}

class _ExamNavTabsState extends State<ExamNavTabs> {
  static const _tabs = [
    _TabItem(label: 'Exam Type', route: AppRoutes.examType),
    _TabItem(label: 'Exam Setup', route: AppRoutes.examSetup),
    _TabItem(label: 'Exam Schedule', route: AppRoutes.examSchedule),
    _TabItem(label: 'Add Marks', route: AppRoutes.examMarksCreate),
    _TabItem(label: 'Marks Register', route: AppRoutes.examMarksRegister),
    _TabItem(label: 'Attend Create', route: AppRoutes.examAttendanceCreate),
    _TabItem(label: 'Attend Report', route: AppRoutes.examAttendanceReport),
    _TabItem(label: 'Result Publish', route: AppRoutes.examResultPublish),
    _TabItem(label: 'Merit Report', route: AppRoutes.examMeritReport),
    _TabItem(label: 'Schedule Report', route: AppRoutes.examScheduleReport),
    _TabItem(label: 'Student Report', route: AppRoutes.examStudentReport),
    _TabItem(label: 'Admit Card', route: AppRoutes.examAdmitCard),
    _TabItem(label: 'Seat Plan', route: AppRoutes.examSeatPlan),
    _TabItem(label: 'Online Exam', route: AppRoutes.onlineExam),
  ];

  final _scrollController = ScrollController();
  final _keys = List.generate(_tabs.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final activeIndex =
        _tabs.indexWhere((t) => t.route == widget.activeRoute);
    if (activeIndex < 0) return;
    final ctx = _keys[activeIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, alignment: 0.5, duration: Duration.zero);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F3FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)])
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: isActive
              ? null
              : Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          tab.label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
