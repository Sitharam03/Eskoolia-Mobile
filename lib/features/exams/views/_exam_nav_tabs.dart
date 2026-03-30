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
          color: isActive
              ? const Color(0xFF4F46E5)
              : const Color(0xFFF3F4F6),
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
