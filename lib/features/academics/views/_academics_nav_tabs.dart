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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
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
