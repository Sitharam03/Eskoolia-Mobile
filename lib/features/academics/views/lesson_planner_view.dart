import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/lesson_planner_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class LessonPlannerView extends GetView<LessonPlannerController> {
  const LessonPlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lesson Planner',
      body: Column(
        children: [
          const AcademicsNavTabs(
              activeRoute: AppRoutes.academicsLessonPlanner),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _PlannerFormCard(controller: controller),
                  const SizedBox(height: 16),
                  _PlannerRowsCard(controller: controller),
                  const SizedBox(height: 16),
                  _WeeklyPlannerCard(controller: controller),
                  const SizedBox(height: 16),
                  _OverviewTableCard(controller: controller),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 1: Form card ──────────────────────────────────────────────────────

class _PlannerFormCard extends StatefulWidget {
  final LessonPlannerController controller;
  const _PlannerFormCard({required this.controller});

  @override
  State<_PlannerFormCard> createState() => _PlannerFormCardState();
}

class _PlannerFormCardState extends State<_PlannerFormCard> {
  LessonPlannerController get c => widget.controller;

  late final TextEditingController _routineIdCtrl;
  late final TextEditingController _lessonDateCtrl;
  late final TextEditingController _subTopicCtrl;
  late final TextEditingController _customTopicIdsCtrl;
  late final TextEditingController _customSubTopicsCtrl;

  static const _dayOptions = [
    DropdownMenuItem(value: '1', child: Text('Monday')),
    DropdownMenuItem(value: '2', child: Text('Tuesday')),
    DropdownMenuItem(value: '3', child: Text('Wednesday')),
    DropdownMenuItem(value: '4', child: Text('Thursday')),
    DropdownMenuItem(value: '5', child: Text('Friday')),
    DropdownMenuItem(value: '6', child: Text('Saturday')),
    DropdownMenuItem(value: '7', child: Text('Sunday')),
  ];

  @override
  void initState() {
    super.initState();
    _routineIdCtrl = TextEditingController(text: c.routineId.value);
    _lessonDateCtrl = TextEditingController(text: c.lessonDate.value);
    _subTopicCtrl = TextEditingController(text: c.subTopic.value);
    _customTopicIdsCtrl =
        TextEditingController(text: c.customTopicIds.value);
    _customSubTopicsCtrl =
        TextEditingController(text: c.customSubTopics.value);
  }

  @override
  void dispose() {
    _routineIdCtrl.dispose();
    _lessonDateCtrl.dispose();
    _subTopicCtrl.dispose();
    _customTopicIdsCtrl.dispose();
    _customSubTopicsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLessonDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(c.lessonDate.value) ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFF4F46E5))),
        child: child!,
      ),
    );
    if (picked != null) {
      final f =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      c.lessonDate.value = f;
      _lessonDateCtrl.text = f;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Add / Edit Lesson Plan',
      icon: Icons.edit_calendar_rounded,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Year
              aDropdown<String>(
                value: c.academicYearId.value.isEmpty
                    ? null
                    : c.academicYearId.value,
                label: 'Academic Year',
                items: [
                  _none(),
                  ...c.years.map((y) => _dd(y.id.toString(), y.name)),
                ],
                onChanged: (v) => c.academicYearId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Day + Teacher
              Row(children: [
                Expanded(
                  child: aDropdown<String>(
                    value: c.day.value,
                    label: 'Day (1–7)',
                    items: _dayOptions,
                    onChanged: (v) => c.day.value = v ?? '1',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: aDropdown<String>(
                    value: c.teacherId.value.isEmpty
                        ? null
                        : c.teacherId.value,
                    label: 'Teacher',
                    items: [
                      _none(),
                      ...c.teachers.map(
                          (t) => _dd(t.id.toString(), t.displayName)),
                    ],
                    onChanged: (v) => c.teacherId.value = v ?? '',
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Class Period
              aDropdown<String>(
                value: c.classPeriodId.value.isEmpty
                    ? null
                    : c.classPeriodId.value,
                label: 'Class Period',
                items: [
                  _none(),
                  ...c.classPeriods
                      .map((p) => _dd(p.id.toString(), p.label)),
                ],
                onChanged: (v) => c.classPeriodId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Class *
              aDropdown<String>(
                value: c.classId.value.isEmpty ? null : c.classId.value,
                label: 'Class *',
                items: c.classes
                    .map((cl) => _dd(cl.id.toString(), cl.name))
                    .toList(),
                onChanged: (v) {
                  c.classId.value = v ?? '';
                  c.sectionId.value = '';
                  c.lessonId.value = '';
                  c.topicId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Section
              aDropdown<String>(
                value: c.sectionId.value.isEmpty ? null : c.sectionId.value,
                label: 'Section',
                items: [
                  _none(),
                  ...c.filteredSections
                      .map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.sectionId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Subject *
              aDropdown<String>(
                value: c.subjectId.value.isEmpty ? null : c.subjectId.value,
                label: 'Subject *',
                items: c.subjects
                    .map((s) => _dd(s.id.toString(), s.name))
                    .toList(),
                onChanged: (v) {
                  c.subjectId.value = v ?? '';
                  c.lessonId.value = '';
                  c.topicId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Lesson
              aDropdown<String>(
                value: c.lessonId.value.isEmpty ? null : c.lessonId.value,
                label: 'Lesson',
                items: [
                  _none(),
                  ...c.filteredLessons
                      .map((l) => _dd(l.id.toString(), l.lessonTitle)),
                ],
                onChanged: (v) {
                  c.lessonId.value = v ?? '';
                  c.topicId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Lesson Date *
              _DateFieldRaw(
                  label: 'Lesson Date *',
                  ctrl: _lessonDateCtrl,
                  onTap: _pickLessonDate),
              const SizedBox(height: 14),

              // Routine ID
              aTextField(_routineIdCtrl, 'Routine ID',
                  hint: 'Optional routine ID',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),

              // Customize Mode switch
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customize Mode',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF111827))),
                      Text('Enable to set multiple topics/subtopics',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: c.customizeMode.value,
                  onChanged: (v) => c.customizeMode.value = v,
                  activeColor: const Color(0xFF4F46E5),
                ),
              ]),
              const SizedBox(height: 14),

              // Conditional topic fields
              if (!c.customizeMode.value) ...[
                aDropdown<String>(
                  value: c.topicId.value.isEmpty ? null : c.topicId.value,
                  label: 'Topic Detail',
                  items: [
                    _none(),
                    ...c.filteredTopics
                        .map((t) => _dd(t.id.toString(), t.topicTitle)),
                  ],
                  onChanged: (v) => c.topicId.value = v ?? '',
                ),
                const SizedBox(height: 14),
                aTextField(_subTopicCtrl, 'Sub Topic',
                    hint: 'Sub topic title...'),
              ] else ...[
                aTextField(_customTopicIdsCtrl, 'Topic IDs (comma separated)',
                    hint: 'e.g. 1, 3, 5'),
                const SizedBox(height: 14),
                aTextField(_customSubTopicsCtrl,
                    'Sub Topics (one per line)',
                    hint: 'Sub topic 1\nSub topic 2', maxLines: 4),
              ],
              const SizedBox(height: 16),

              // Error / success
              if (c.error.value.isNotEmpty)
                _StatusBanner(message: c.error.value, isError: true),
              if (c.message.value.isNotEmpty)
                _StatusBanner(message: c.message.value, isError: false),

              // Buttons
              Row(children: [
                Expanded(
                  child: aPrimaryBtn(
                    c.editingPlannerId.value != null
                        ? 'Update Plan'
                        : 'Save Plan',
                    c.isSaving.value
                        ? null
                        : () {
                            c.routineId.value = _routineIdCtrl.text;
                            c.subTopic.value = _subTopicCtrl.text;
                            c.customTopicIds.value =
                                _customTopicIdsCtrl.text;
                            c.customSubTopics.value =
                                _customSubTopicsCtrl.text;
                            c.submitPlanner();
                          },
                    isLoading: c.isSaving.value,
                  ),
                ),
                if (c.editingPlannerId.value != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: aSecondaryBtn(
                      'Cancel Edit',
                      () {
                        c.resetForm();
                        _routineIdCtrl.clear();
                        _lessonDateCtrl.clear();
                        _subTopicCtrl.clear();
                        _customTopicIdsCtrl.clear();
                        _customSubTopicsCtrl.clear();
                      },
                    ),
                  ),
                ],
              ]),
            ],
          )),
    );
  }

  static DropdownMenuItem<String> _none() =>
      DropdownMenuItem(
          value: '',
          child: Text('-- None --',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));

  static DropdownMenuItem<String> _dd(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF111827))));
}

// ── Section 2: Planner rows table ─────────────────────────────────────────────

class _PlannerRowsCard extends StatelessWidget {
  final LessonPlannerController controller;
  const _PlannerRowsCard({required this.controller});

  LessonPlannerController get c => controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Planner Rows',
      icon: Icons.table_rows_rounded,
      child: Obx(() {
        if (c.isLoading.value) {
          return const SchoolLoader();
        }
        if (c.planners.isEmpty) {
          return aEmptyState('No lesson plans found.');
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF9FAFB)),
            headingTextStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: const Color(0xFF374151)),
            dataTextStyle: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF374151)),
            border: TableBorder.all(
                color: const Color(0xFFE5E7EB), width: 1),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Period')),
              DataColumn(label: Text('Lesson')),
              DataColumn(label: Text('Topic')),
              DataColumn(label: Text('Sub Topic')),
              DataColumn(label: Text('Actions')),
            ],
            rows: c.planners.map((row) {
              return DataRow(cells: [
                DataCell(Text('#${row.id}')),
                DataCell(Text(row.lessonDate)),
                DataCell(Text(row.classPeriodId != null
                    ? _periodLabel(c, row.classPeriodId!)
                    : '-')),
                DataCell(Text(c.lessonTitle(row.lessonDetailId))),
                DataCell(Text(c.topicTitle(row.topicDetailId))),
                DataCell(ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(row.subTopic,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                )),
                DataCell(Row(children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: Color(0xFF4F46E5), size: 18),
                    onPressed: () => c.fillPlannerForm(row),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626), size: 18),
                    onPressed: () => _confirmDelete(context, row.id),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Delete',
                  ),
                ])),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }

  String _periodLabel(LessonPlannerController c, int id) {
    final p = c.classPeriods.firstWhereOrNull((p) => p.id == id);
    return p?.label ?? '#$id';
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Lesson Plan',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Delete lesson plan #$id?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePlanner(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Section 3: Weekly planner ─────────────────────────────────────────────────

class _WeeklyPlannerCard extends StatefulWidget {
  final LessonPlannerController controller;
  const _WeeklyPlannerCard({required this.controller});

  @override
  State<_WeeklyPlannerCard> createState() => _WeeklyPlannerCardState();
}

class _WeeklyPlannerCardState extends State<_WeeklyPlannerCard> {
  LessonPlannerController get c => widget.controller;
  late final TextEditingController _startDateCtrl;

  @override
  void initState() {
    super.initState();
    _startDateCtrl =
        TextEditingController(text: c.weeklyStartDate.value);
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFF4F46E5))),
        child: child!,
      ),
    );
    if (picked != null) {
      final f =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      c.weeklyStartDate.value = f;
      _startDateCtrl.text = f;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Weekly Planner',
      icon: Icons.view_week_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: _DateFieldRaw(
                  label: 'Start Date',
                  ctrl: _startDateCtrl,
                  onTap: _pickStartDate),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => c.loadWeekly(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              child: Text('Load Week',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 16),
          Obx(() {
            final w = c.weekly.value;
            if (w == null || w.days.isEmpty) {
              return aEmptyState(
                  'Select a start date and load the weekly schedule.');
            }
            return _WeeklyGrid(weekly: w, controller: c);
          }),
        ],
      ),
    );
  }
}

class _WeeklyGrid extends StatelessWidget {
  final WeeklyPlanner weekly;
  final LessonPlannerController controller;
  const _WeeklyGrid({required this.weekly, required this.controller});

  LessonPlannerController get c => controller;

  static const _dayNames = {
    '1': 'Mon',
    '2': 'Tue',
    '3': 'Wed',
    '4': 'Thu',
    '5': 'Fri',
    '6': 'Sat',
    '7': 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    final dayKeys = weekly.days.keys.toList()..sort();

    // Collect all unique period IDs
    final periodIds = <int>{};
    for (final rows in weekly.days.values) {
      for (final row in rows) {
        if (row.classPeriodId != null) periodIds.add(row.classPeriodId!);
      }
    }
    final sortedPeriods = periodIds.toList()..sort();

    if (sortedPeriods.isEmpty) {
      return Text('No period data in this week.',
          style: GoogleFonts.inter(
              fontSize: 13, color: const Color(0xFF9CA3AF)));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
            color: const Color(0xFFE5E7EB), width: 1),
        defaultColumnWidth: const FixedColumnWidth(140),
        children: [
          // Header row
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF5F3FF)),
            children: [
              _TC(
                child: Text('Period',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              ...dayKeys.map((day) => _TC(
                    child: Text(_dayNames[day] ?? day,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: const Color(0xFF4F46E5))),
                  )),
            ],
          ),
          // Period rows
          ...sortedPeriods.map((periodId) {
            final period = c.classPeriods
                .firstWhereOrNull((p) => p.id == periodId);
            return TableRow(
              children: [
                _TC(
                  child: Text(period?.label ?? '#$periodId',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151))),
                ),
                ...dayKeys.map((day) {
                  final dayRows = weekly.days[day] ?? [];
                  final match = dayRows.firstWhereOrNull(
                      (r) => r.classPeriodId == periodId);
                  if (match == null) {
                    return _TC(
                      child: Text('-',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFD1D5DB))),
                    );
                  }
                  return _TC(
                    child: _MiniCard(row: match, controller: c),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TC extends StatelessWidget {
  final Widget child;
  const _TC({required this.child});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final PlannerRow row;
  final LessonPlannerController controller;
  const _MiniCard({required this.row, required this.controller});

  LessonPlannerController get c => controller;

  @override
  Widget build(BuildContext context) {
    final period =
        c.classPeriods.firstWhereOrNull((p) => p.id == row.classPeriodId);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (period != null)
            Text(period.period,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5))),
          Text(c.lessonTitle(row.lessonDetailId),
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF374151)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(c.teacherName(row.teacherId),
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (row.topicDetailId != null)
            Text(c.topicTitle(row.topicDetailId),
                style: GoogleFonts.inter(
                    fontSize: 9, color: const Color(0xFF9CA3AF)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Section 4: Overview table ─────────────────────────────────────────────────

class _OverviewTableCard extends StatelessWidget {
  final LessonPlannerController controller;
  const _OverviewTableCard({required this.controller});

  LessonPlannerController get c => controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Planner Overview',
      icon: Icons.analytics_rounded,
      child: Obx(() {
        if (c.overviewItems.isEmpty) {
          return aEmptyState('No overview data.');
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF9FAFB)),
            headingTextStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: const Color(0xFF374151)),
            dataTextStyle: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF374151)),
            border: TableBorder.all(
                color: const Color(0xFFE5E7EB), width: 1),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Planner ID')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Section')),
              DataColumn(label: Text('Subject')),
            ],
            rows: c.overviewItems.map((row) {
              return DataRow(cells: [
                DataCell(Text('#${row.id}')),
                DataCell(Text(row.lessonDate)),
                DataCell(Text(c.className(row.classId))),
                DataCell(Text(c.sectionName(row.sectionId))),
                DataCell(Text(c.subjectName(row.subjectId))),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F3FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF4F46E5), size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF4F46E5))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }
}

class _DateFieldRaw extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final VoidCallback onTap;
  const _DateFieldRaw(
      {required this.label, required this.ctrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
        suffixIcon: const Icon(Icons.calendar_today_rounded,
            size: 18, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final bg =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: GoogleFonts.inter(
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
