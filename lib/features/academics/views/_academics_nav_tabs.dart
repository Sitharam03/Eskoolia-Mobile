import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';

/// Horizontal scrollable pill-chip tab bar for all Academics views.
class AcademicsNavTabs extends StatefulWidget {
  final String activeRoute;
  const AcademicsNavTabs({super.key, required this.activeRoute});

  @override
  State<AcademicsNavTabs> createState() => _AcademicsNavTabsState();
}

class _AcademicsNavTabsState extends State<AcademicsNavTabs> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _keys;

  static const _tabs = <_TabDef>[
    _TabDef('Core Setup', AppRoutes.academicsCoreSetup),
    _TabDef('Assign Class Teacher', AppRoutes.academicsAssignClassTeacher),
    _TabDef('Assign Subject', AppRoutes.academicsAssignSubject),
    _TabDef('Class Room', AppRoutes.academicsClassRoom),
    _TabDef('Class Routine', AppRoutes.academicsClassRoutine),
    _TabDef('Lesson', AppRoutes.academicsLessons),
    _TabDef('Topic', AppRoutes.academicsTopics),
    _TabDef('Lesson Planner', AppRoutes.academicsLessonPlanner),
    _TabDef('Add Homework', AppRoutes.academicsHomeworkAdd),
    _TabDef('Homework List', AppRoutes.academicsHomeworkList),
    _TabDef('Homework Evaluation Report', AppRoutes.academicsHomeworkEvalReport),
    _TabDef('Upload Content', AppRoutes.academicsUploadContent),
    _TabDef('Assignment List', AppRoutes.academicsAssignmentList),
    _TabDef('Study Material List', AppRoutes.academicsStudyMaterialList),
    _TabDef('Syllabus List', AppRoutes.academicsSyllabusList),
    _TabDef('Other Downloads List', AppRoutes.academicsOtherDownloadsList),
  ];

  @override
  void initState() {
    super.initState();
    _keys = List.generate(_tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final activeIndex =
        _tabs.indexWhere((t) => t.route == widget.activeRoute);
    if (activeIndex < 0) return;
    final ctx = _keys[activeIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: Duration.zero,
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
              _AcademicsChip(
                key: _keys[i],
                label: _tabs[i].label,
                route: _tabs[i].route,
                isActive: _tabs[i].route == widget.activeRoute,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabDef {
  final String label;
  final String route;
  const _TabDef(this.label, this.route);
}

class _AcademicsChip extends StatelessWidget {
  final String label;
  final String route;
  final bool isActive;

  const _AcademicsChip({
    super.key,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) Get.offNamed(route);
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
          label,
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
