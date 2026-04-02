import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/class_routine_controller.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class ClassRoutineView extends GetView<ClassRoutineController> {
  const ClassRoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Class Routine',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsClassRoutine),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: controller.loadItems,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _DayChips(c: controller),
                    const SizedBox(height: 12),
                    _FilterCard(c: controller),
                    const SizedBox(height: 12),
                    _FormCard(c: controller),
                    const SizedBox(height: 12),
                    _Messages(c: controller),
                    _ItemList(c: controller),
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

// ── Day chip row ──────────────────────────────────────────────────────────────

class _DayChips extends StatelessWidget {
  final ClassRoutineController c;
  const _DayChips({required this.c});

  static const _labels = {
    'monday': 'Mon',
    'tuesday': 'Tue',
    'wednesday': 'Wed',
    'thursday': 'Thu',
    'friday': 'Fri',
    'saturday': 'Sat',
    'sunday': 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: ClassRoutineController.days.map((day) {
                final active = c.activeDayTab.value == day;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => c.activeDayTab.value = day,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border: active
                            ? null
                            : Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        _labels[day] ?? day,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final ClassRoutineController c;
  const _FilterCard({required this.c});

  double _fieldWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 64;
    return w >= 600 ? (w - 12) / 2 : w;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          aSectionHeader('Filter'),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: _fieldWidth(context),
                    child: aDropdown<String>(
                      value: c.filterClassId.value.isEmpty
                          ? null
                          : c.filterClassId.value,
                      label: 'Class',
                      items: [
                        DropdownMenuItem(
                            value: '',
                            child: Text('All Classes',
                                style: GoogleFonts.inter(fontSize: 14))),
                        ...c.classes.map((cl) => DropdownMenuItem(
                              value: cl.id.toString(),
                              child: Text(cl.name,
                                  style: GoogleFonts.inter(fontSize: 14)),
                            )),
                      ],
                      onChanged: (v) {
                        c.filterClassId.value = v ?? '';
                        c.filterSectionId.value = '';
                      },
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context),
                    child: aDropdown<String>(
                      value: c.filterSectionId.value.isEmpty
                          ? null
                          : c.filterSectionId.value,
                      label: 'Section',
                      items: [
                        DropdownMenuItem(
                            value: '',
                            child: Text('All Sections',
                                style: GoogleFonts.inter(fontSize: 14))),
                        ...c.filterSections.map((s) => DropdownMenuItem(
                              value: s.id.toString(),
                              child: Text(s.name,
                                  style: GoogleFonts.inter(fontSize: 14)),
                            )),
                      ],
                      onChanged: (v) => c.filterSectionId.value = v ?? '',
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: c.loadItems,
                        icon: const Icon(Icons.search_rounded, size: 16),
                        label: Text('Search',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          c.filterClassId.value = '';
                          c.filterSectionId.value = '';
                          c.loadItems();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Reset',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatefulWidget {
  final ClassRoutineController c;
  const _FormCard({required this.c});

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endTimeCtrl;
  late final TextEditingController _roomTextCtrl;

  ClassRoutineController get c => widget.c;

  @override
  void initState() {
    super.initState();
    _startTimeCtrl = TextEditingController(text: c.startTime.value);
    _endTimeCtrl = TextEditingController(text: c.endTime.value);
    _roomTextCtrl = TextEditingController(text: c.roomText.value);

    // Sync observables → text fields (for period auto-fill)
    ever(c.startTime, (v) {
      if (_startTimeCtrl.text != v) _startTimeCtrl.text = v;
    });
    ever(c.endTime, (v) {
      if (_endTimeCtrl.text != v) _endTimeCtrl.text = v;
    });
    ever(c.roomText, (v) {
      if (_roomTextCtrl.text != v) _roomTextCtrl.text = v;
    });

    // Sync text fields → observables
    _startTimeCtrl.addListener(() => c.startTime.value = _startTimeCtrl.text);
    _endTimeCtrl.addListener(() => c.endTime.value = _endTimeCtrl.text);
    _roomTextCtrl.addListener(() => c.roomText.value = _roomTextCtrl.text);
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _roomTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = c.editingId.value != null;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: aCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            aSectionHeader(isEditing ? 'Edit Routine Slot' : 'Add Routine Slot'),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (ctx, constraints) {
              final wide = constraints.maxWidth >= 500;
              return _buildFormFields(ctx, wide);
            }),
            // Break switch
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: Text('Is Break',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                    'Mark this slot as a break period',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF6B7280))),
                value: c.isBreak.value,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (v) => c.isBreak.value = v,
              ),
            ),
            const SizedBox(height: 16),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                      child: aSecondaryBtn('Cancel', () => c.resetForm())),
                  const SizedBox(width: 12),
                  Expanded(
                      child: aPrimaryBtn('Update', c.save,
                          isLoading: c.isSaving.value)),
                ],
              )
            else
              aPrimaryBtn('Add Slot', c.save, isLoading: c.isSaving.value),
          ],
        ),
      );
    });
  }

  Widget _buildFormFields(BuildContext context, bool wide) {
    final fields = <Widget>[
      aDropdown<String>(
        value: c.yearId.value.isEmpty ? null : c.yearId.value,
        label: 'Academic Year',
        items: c.years
            .map((y) => DropdownMenuItem(
                  value: y.id.toString(),
                  child: Text(y.name, style: GoogleFonts.inter(fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) => c.yearId.value = v ?? '',
      ),
      aDropdown<String>(
        value: c.classId.value.isEmpty ? null : c.classId.value,
        label: 'Class *',
        items: c.classes
            .map((cl) => DropdownMenuItem(
                  value: cl.id.toString(),
                  child: Text(cl.name, style: GoogleFonts.inter(fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) {
          c.classId.value = v ?? '';
          c.sectionId.value = '';
        },
      ),
      aDropdown<String>(
        value: c.sectionId.value.isEmpty ? null : c.sectionId.value,
        label: 'Section',
        items: [
          DropdownMenuItem(
              value: '',
              child: Text('None', style: GoogleFonts.inter(fontSize: 14))),
          ...c.availableSections.map((s) => DropdownMenuItem(
                value: s.id.toString(),
                child: Text(s.name, style: GoogleFonts.inter(fontSize: 14)),
              )),
        ],
        onChanged: (v) => c.sectionId.value = v ?? '',
      ),
      aDropdown<String>(
        value: c.subjectId.value.isEmpty ? null : c.subjectId.value,
        label: c.isBreak.value ? 'Subject (optional)' : 'Subject *',
        items: [
          DropdownMenuItem(
              value: '',
              child: Text('None', style: GoogleFonts.inter(fontSize: 14))),
          ...c.subjects.map((s) => DropdownMenuItem(
                value: s.id.toString(),
                child: Text(s.name, style: GoogleFonts.inter(fontSize: 14)),
              )),
        ],
        onChanged: (v) => c.subjectId.value = v ?? '',
      ),
      aDropdown<String>(
        value: c.teacherId.value.isEmpty ? null : c.teacherId.value,
        label: 'Teacher',
        items: [
          DropdownMenuItem(
              value: '',
              child: Text('None', style: GoogleFonts.inter(fontSize: 14))),
          ...c.teachers.map((t) => DropdownMenuItem(
                value: t.id.toString(),
                child: Text(t.displayName,
                    style: GoogleFonts.inter(fontSize: 14)),
              )),
        ],
        onChanged: (v) => c.teacherId.value = v ?? '',
      ),
      aDropdown<String>(
        value: c.day.value,
        label: 'Day *',
        items: ClassRoutineController.days
            .map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(
                      d[0].toUpperCase() + d.substring(1),
                      style: GoogleFonts.inter(fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) => c.day.value = v ?? 'monday',
      ),
      aDropdown<String>(
        value: c.periodId.value.isEmpty ? null : c.periodId.value,
        label: 'Period *',
        items: [
          DropdownMenuItem(
              value: '',
              child: Text('Select Period',
                  style: GoogleFonts.inter(fontSize: 14))),
          ...c.periods.map((p) => DropdownMenuItem(
                value: p.id.toString(),
                child: Text(p.label, style: GoogleFonts.inter(fontSize: 14)),
              )),
        ],
        onChanged: (v) => c.periodId.value = v ?? '',
      ),
      aTextField(_startTimeCtrl, 'Start Time', hint: 'HH:MM'),
      aTextField(_endTimeCtrl, 'End Time', hint: 'HH:MM'),
      aDropdown<String>(
        value: c.roomId.value.isEmpty ? null : c.roomId.value,
        label: 'Room (optional)',
        items: [
          DropdownMenuItem(
              value: '',
              child: Text('None', style: GoogleFonts.inter(fontSize: 14))),
          ...c.rooms.map((r) => DropdownMenuItem(
                value: r.id.toString(),
                child:
                    Text(r.roomNo, style: GoogleFonts.inter(fontSize: 14)),
              )),
        ],
        onChanged: (v) => c.roomId.value = v ?? '',
      ),
      aTextField(_roomTextCtrl, 'Room Label (optional)',
          hint: 'e.g. Science Lab'),
    ];

    if (wide) {
      return Column(
        children: [
          for (int i = 0; i < fields.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: fields[i]),
                  if (i + 1 < fields.length) ...[
                    const SizedBox(width: 12),
                    Expanded(child: fields[i + 1]),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      );
    }

    return Column(
      children: fields
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: f,
              ))
          .toList(),
    );
  }
}

// ── Messages ──────────────────────────────────────────────────────────────────

class _Messages extends StatelessWidget {
  final ClassRoutineController c;
  const _Messages({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.error.value.isNotEmpty) {
        return _banner(c.error.value, const Color(0xFFFEE2E2),
            const Color(0xFFDC2626), Icons.error_outline_rounded);
      }
      if (c.message.value.isNotEmpty) {
        return _banner(c.message.value, const Color(0xFFD1FAE5),
            const Color(0xFF059669), Icons.check_circle_outline_rounded);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _banner(String text, Color bg, Color fg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: fg, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Item list ─────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final ClassRoutineController c;
  const _ItemList({required this.c});

  static const _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: aSavingIndicator(),
        );
      }

      final slots = c.itemsForActiveDay;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: aSectionHeader(
                '${_dayLabels[c.activeDayTab.value] ?? c.activeDayTab.value} — ${slots.length} slot(s)'),
          ),
          if (slots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: aEmptyState(
                  'No routine slots for this day.\nAdd one using the form above.'),
            )
          else
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              if (wide) {
                return _gridLayout(context, slots, 2);
              }
              return Column(
                children: slots.map((slot) => _SlotCard(c: c, slot: slot)).toList(),
              );
            }),
        ],
      );
    });
  }

  Widget _gridLayout(BuildContext context, List items, int cols) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += cols) {
      final rowItems = items.sublist(
          i, (i + cols) > items.length ? items.length : i + cols);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int j = 0; j < rowItems.length; j++) ...[
              if (j > 0) const SizedBox(width: 10),
              Expanded(child: _SlotCard(c: c, slot: rowItems[j])),
            ],
            if (rowItems.length < cols)
              ...List.generate(
                  cols - rowItems.length,
                  (_) => const Expanded(child: SizedBox.shrink())),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _SlotCard extends StatelessWidget {
  final ClassRoutineController c;
  final dynamic slot;
  const _SlotCard({required this.c, required this.slot});

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        (slot.startTime.isNotEmpty && slot.endTime.isNotEmpty)
            ? '${slot.startTime} – ${slot.endTime}'
            : c.periodName(slot.classPeriodId);

    final roomLabel = slot.roomId != null
        ? c.roomName(slot.roomId)
        : slot.room.isNotEmpty
            ? slot.room
            : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  slot.isBreak
                      ? 'Break'
                      : c.subjectName(
                          slot.subjectId == 0 ? null : slot.subjectId),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              if (slot.isBreak)
                aBadge('Break', const Color(0xFFF59E0B))
              else ...[
                aIconBtn(Icons.edit_rounded, const Color(0xFF4F46E5),
                    () => c.startEdit(slot)),
                aIconBtn(Icons.delete_rounded, const Color(0xFFDC2626),
                    () async {
                  final ok = await aDeleteDialog(
                    context,
                    'Delete this routine slot?',
                  );
                  if (ok) c.delete(slot.id);
                }),
              ],
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.schedule_rounded, timeLabel),
          if (c.teacherName(slot.teacherId) != '-')
            _infoRow(Icons.person_rounded, c.teacherName(slot.teacherId)),
          _infoRow(Icons.meeting_room_rounded, roomLabel),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }
}
