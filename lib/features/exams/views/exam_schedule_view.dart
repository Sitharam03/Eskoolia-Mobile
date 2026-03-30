import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/students/views/_student_shared.dart';
import '../controllers/exam_schedule_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';

class ExamScheduleView extends StatelessWidget {
  const ExamScheduleView({super.key});

  ExamScheduleController get _c => Get.find<ExamScheduleController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Exam Schedule',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examSchedule),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CriteriaCard(c: _c),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (_c.routineRows.isEmpty) return const SizedBox.shrink();
                      return _RoutineCard(c: _c);
                    }),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (_c.existingRoutines.isEmpty) return const SizedBox.shrink();
                      return _ExistingScheduleCard(c: _c);
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Criteria Card ────────────────────────────────────────────────────────────

class _CriteriaCard extends StatelessWidget {
  final ExamScheduleController c;
  const _CriteriaCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Criteria',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 14),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Exam Type *',
                value: c.selectedExamTypeId.value,
                hint: 'Select Exam Type',
                items: c.examTypes
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.title)))
                    .toList(),
                onChanged: (v) => c.selectedExamTypeId.value = v,
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Class *',
                value: c.selectedClassId.value,
                hint: 'Select Class',
                items: c.classes
                    .map((cl) =>
                        DropdownMenuItem(value: cl.id, child: Text(cl.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedClassId.value = v;
                  c.selectedSectionId.value = null;
                },
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Section',
                value: c.selectedSectionId.value,
                hint: 'All Sections',
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Sections')),
                  ...c.filteredSections.map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) => c.selectedSectionId.value = v,
              )),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      c.isSearching.value ? null : c.search,
                  icon: c.isSearching.value
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded, size: 18),
                  label: Text(
                      c.isSearching.value ? 'Searching...' : 'Search',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )),
          Obx(() {
            if (c.errorMsg.value.isNotEmpty) {
              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _StatusBanner(
                      message: c.errorMsg.value, isError: true));
            }
            if (c.successMsg.value.isNotEmpty) {
              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _StatusBanner(
                      message: c.successMsg.value, isError: false));
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ── Routine Input Card ───────────────────────────────────────────────────────

class _RoutineCard extends StatelessWidget {
  final ExamScheduleController c;
  const _RoutineCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exam Routine',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: List.generate(
                  c.routineRows.length,
                  (i) => _RoutineRowItem(index: i, c: c),
                ),
              )),
          const SizedBox(height: 14),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isSaving.value ? null : c.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: c.isSaving.value
                      ? sSavingIndicator()
                      : Text('Save Routine',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              )),
        ],
      ),
    );
  }
}

class _RoutineRowItem extends StatefulWidget {
  final int index;
  final ExamScheduleController c;
  const _RoutineRowItem({required this.index, required this.c});

  @override
  State<_RoutineRowItem> createState() => _RoutineRowItemState();
}

class _RoutineRowItemState extends State<_RoutineRowItem> {
  late TextEditingController _dateCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _roomCtrl;

  @override
  void initState() {
    super.initState();
    final row = widget.c.routineRows[widget.index];
    _dateCtrl = TextEditingController(text: row.date);
    _startCtrl = TextEditingController(text: row.startTime);
    _endCtrl = TextEditingController(text: row.endTime);
    _roomCtrl = TextEditingController(text: row.room);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  void _patch(RoutineRow Function(RoutineRow) updater) {
    final current = widget.c.routineRows[widget.index];
    widget.c.updateRow(widget.index, updater(current));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Obx(() {
      final row = c.routineRows[widget.index];
      final subject = c.subjects
          .where((s) => s.id == row.subject)
          .firstOrNull;
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subject?.name ?? 'Subject #${row.subject}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5)),
              ),
            ),
            const SizedBox(height: 10),
            // Date
            sFieldLabel('Date'),
            const SizedBox(height: 4),
            sTextField(
              controller: _dateCtrl,
              hint: 'YYYY-MM-DD',
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(row.date) ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: Color(0xFF4F46E5)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  final formatted =
                      picked.toIso8601String().substring(0, 10);
                  _dateCtrl.text = formatted;
                  _patch((r) => r.copyWith(date: formatted));
                }
              },
              suffixIcon: const Icon(Icons.calendar_today_rounded,
                  size: 16, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sFieldLabel('Start Time'),
                      const SizedBox(height: 4),
                      sTextField(
                        controller: _startCtrl,
                        hint: '09:00',
                        readOnly: true,
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(row.startTime),
                          );
                          if (t != null) {
                            final v =
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                            _startCtrl.text = v;
                            _patch((r) => r.copyWith(startTime: v));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sFieldLabel('End Time'),
                      const SizedBox(height: 4),
                      sTextField(
                        controller: _endCtrl,
                        hint: '10:00',
                        readOnly: true,
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(row.endTime),
                          );
                          if (t != null) {
                            final v =
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                            _endCtrl.text = v;
                            _patch((r) => r.copyWith(endTime: v));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Teacher
            sFieldLabel('Teacher'),
            const SizedBox(height: 4),
            sDropdown<int?>(
              value: row.teacherId,
              hint: 'Select Teacher',
              items: [
                const DropdownMenuItem(value: null, child: Text('Select Teacher')),
                ...c.teachers.map((t) =>
                    DropdownMenuItem(value: t.id, child: Text(t.fullName))),
              ],
              onChanged: (v) => _patch((r) => r.copyWith(teacherId: v)),
            ),
            const SizedBox(height: 8),
            // Period
            sFieldLabel('Exam Period'),
            const SizedBox(height: 4),
            sDropdown<int?>(
              value: row.examPeriodId,
              hint: 'Select Period',
              items: [
                const DropdownMenuItem(value: null, child: Text('Select Period')),
                ...c.periods.map((p) =>
                    DropdownMenuItem(value: p.id, child: Text(p.period))),
              ],
              onChanged: (v) => _patch((r) => r.copyWith(examPeriodId: v)),
            ),
            const SizedBox(height: 8),
            // Section
            sFieldLabel('Section'),
            const SizedBox(height: 4),
            sDropdown<int?>(
              value: row.section,
              hint: 'All Sections',
              items: [
                const DropdownMenuItem(value: null, child: Text('All Sections')),
                ...c.filteredSections.map((s) =>
                    DropdownMenuItem(value: s.id, child: Text(s.name))),
              ],
              onChanged: (v) => _patch((r) => r.copyWith(section: v)),
            ),
            const SizedBox(height: 8),
            // Room
            sFieldLabel('Room'),
            const SizedBox(height: 4),
            sTextField(
              controller: _roomCtrl,
              hint: 'Room number',
              onChanged: (v) => _patch((r) => r.copyWith(room: v)),
            ),
          ],
        ),
      );
    });
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return TimeOfDay.now();
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0);
  }
}

// ── Existing Schedule Card ───────────────────────────────────────────────────

class _ExistingScheduleCard extends StatelessWidget {
  final ExamScheduleController c;
  const _ExistingScheduleCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Existing Schedule',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: c.existingRoutines
                    .map((r) => _ExistingRow(routine: r))
                    .toList(),
              )),
        ],
      ),
    );
  }
}

class _ExistingRow extends StatelessWidget {
  final ExistingRoutine routine;
  const _ExistingRow({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(routine.subjectName,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF111827))),
              ),
              sBadge(routine.examDate, const Color(0xFF4F46E5)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 6, children: [
            sBadge('${routine.className} (${routine.sectionName.isEmpty ? 'All' : routine.sectionName})',
                const Color(0xFF0EA5E9)),
            sBadge(
                '${routine.startTime} - ${routine.endTime}', const Color(0xFF059669)),
            if (routine.teacherName.isNotEmpty)
              sBadge(routine.teacherName, const Color(0xFF7C3AED)),
            if (routine.room.isNotEmpty)
              sBadge('Room: ${routine.room}', const Color(0xFF6B7280)),
          ]),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel(label),
          const SizedBox(height: 6),
          sDropdown<T>(
            value: value,
            hint: hint,
            items: items,
            onChanged: onChanged,
          ),
        ],
      );
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: GoogleFonts.inter(fontSize: 13, color: color)),
    );
  }
}
