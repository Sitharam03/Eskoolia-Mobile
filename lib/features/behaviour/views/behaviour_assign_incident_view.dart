import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_assignment_controller.dart';
import '../models/behaviour_models.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';
import '../../../core/widgets/school_loader.dart';

class BehaviourAssignIncidentView extends StatelessWidget {
  const BehaviourAssignIncidentView({super.key});

  BehaviourAssignmentController get _c =>
      Get.find<BehaviourAssignmentController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(
              activeRoute: AppRoutes.behaviourAssignIncident),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.allStudents.isEmpty) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AssignFormSection(controller: _c),
                      const SizedBox(height: 16),
                      _AssignmentListSection(controller: _c),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Assign Form Section ───────────────────────────────────────────────────────

class _AssignFormSection extends StatefulWidget {
  final BehaviourAssignmentController controller;
  const _AssignFormSection({required this.controller});

  @override
  State<_AssignFormSection> createState() => _AssignFormSectionState();
}

class _AssignFormSectionState extends State<_AssignFormSection> {
  bool _expanded = true;

  BehaviourAssignmentController get _c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: bCardDecoration(borderColor: kBehPrimary.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (toggle) ──────────────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kBehPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_add,
                        color: kBehPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Incident',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Assign incidents to one or more students',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: kBehGray),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: kBehGray,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Academic Year ─────────────────────────────────────
                  bLabel('Academic Year'),
                  Obx(() => bDropdown<int?>(
                        hint: 'Select year (optional)',
                        value: _c.assignYearId.value,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Any Year')),
                          ..._c.academicYears.map((y) => DropdownMenuItem(
                              value: y.id, child: Text(y.title))),
                        ],
                        onChanged: (v) => _c.assignYearId.value = v,
                      )),
                  const SizedBox(height: 10),
                  // ── Class + Section ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bLabel('Class'),
                            Obx(() => bDropdown<int?>(
                                  hint: 'All Classes',
                                  value: _c.assignClassId.value,
                                  items: [
                                    const DropdownMenuItem(
                                        value: null,
                                        child: Text('All Classes')),
                                    ..._c.classes.map((c) => DropdownMenuItem(
                                        value: c.id, child: Text(c.name))),
                                  ],
                                  onChanged: (v) {
                                    _c.assignClassId.value = v;
                                    _c.assignSectionId.value = null;
                                    _c.clearStudents();
                                  },
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bLabel('Section'),
                            Obx(() => bDropdown<int?>(
                                  hint: 'All Sections',
                                  value: _c.assignSectionId.value,
                                  items: [
                                    const DropdownMenuItem(
                                        value: null,
                                        child: Text('All Sections')),
                                    ..._c.assignSections.map((s) =>
                                        DropdownMenuItem(
                                            value: s.id,
                                            child: Text(s.name))),
                                  ],
                                  onChanged: (v) {
                                    _c.assignSectionId.value = v;
                                    _c.clearStudents();
                                  },
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── Incident picker ───────────────────────────────────
                  Row(
                    children: [
                      Text('Select Incidents *',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827))),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _c.clearIncidents,
                        icon: const Icon(Icons.clear_all, size: 15),
                        label: Text('Clear',
                            style: GoogleFonts.inter(fontSize: 12)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (_c.incidents.isEmpty) {
                      return Text('No incidents available.',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: kBehGray));
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _c.incidents.map((inc) {
                        final selected =
                            _c.selectedIncidentIds.contains(inc.id);
                        return GestureDetector(
                          onTap: () => _c.toggleIncident(inc.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kBehPrimary
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected
                                      ? kBehPrimary
                                      : const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 13,
                                  color: selected ? Colors.white : kBehGray,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${inc.title}  (${inc.point >= 0 ? '+' : ''}${inc.point})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF374151),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 14),
                  // ── Student picker ────────────────────────────────────
                  Row(
                    children: [
                      Text('Select Students *',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827))),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _c.selectAllStudents,
                        icon: const Icon(Icons.select_all, size: 15),
                        label:
                            Text('All', style: GoogleFonts.inter(fontSize: 12)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _c.clearStudents,
                        icon: const Icon(Icons.clear_all, size: 15),
                        label: Text('Clear',
                            style: GoogleFonts.inter(fontSize: 12)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final classId = _c.assignClassId.value;
                    final sectionId = _c.assignSectionId.value;
                    final students = _c.filteredStudents;

                    if (classId == null && sectionId == null) {
                      return _SelectClassHint(
                          total: _c.allStudents.length);
                    }
                    if (students.isEmpty) {
                      return Text(
                        'No students found for the selected class/section.',
                        style:
                            GoogleFonts.inter(fontSize: 13, color: kBehGray),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${students.length} student${students.length == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: kBehGray),
                        ),
                        const SizedBox(height: 6),
                        ...students.map((s) {
                          final selected =
                              _c.selectedStudentIds.contains(s.id);
                          return GestureDetector(
                            onTap: () => _c.toggleStudent(s.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: selected
                                    ? kBehPrimary.withOpacity(0.06)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: selected
                                        ? kBehPrimary
                                        : const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    size: 18,
                                    color:
                                        selected ? kBehPrimary : kBehGray,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name.isNotEmpty
                                              ? s.name
                                              : 'Student #${s.id}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF111827),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (s.admissionNo.isNotEmpty)
                                          Text(s.admissionNo,
                                              style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: kBehGray)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  // ── Submit ────────────────────────────────────────────
                  Obx(() {
                    final sCount = _c.selectedStudentIds.length;
                    final iCount = _c.selectedIncidentIds.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sCount > 0 || iCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                bChip(Icons.people,
                                    '$sCount student(s) selected', kBehBlue),
                                bChip(Icons.warning_amber,
                                    '$iCount incident(s) selected', kBehAmber),
                              ],
                            ),
                          ),
                        bPrimaryBtn(
                          label: 'Assign Incidents',
                          loading: _c.bulkLoading.value,
                          onPressed: _c.submitBulkAssign,
                          icon: Icons.assignment_add,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Assignment List Section ───────────────────────────────────────────────────

class _AssignmentListSection extends StatelessWidget {
  final BehaviourAssignmentController controller;
  const _AssignmentListSection({required this.controller});

  BehaviourAssignmentController get _c => controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filters ──────────────────────────────────────────────────────
        bFilterBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bSectionHeader('Filter Assignments'),
              bLabel('Search Student'),
              bTextField(_c.searchCtrl, 'Name / Admission No.'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bLabel('Year'),
                        Obx(() => bDropdown<int?>(
                              hint: 'Any',
                              value: _c.filterYearId.value,
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Any Year')),
                                ..._c.academicYears.map((y) => DropdownMenuItem(
                                    value: y.id, child: Text(y.title))),
                              ],
                              onChanged: (v) => _c.filterYearId.value = v,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bLabel('Class'),
                        Obx(() => bDropdown<int?>(
                              hint: 'All',
                              value: _c.filterClassId.value,
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('All Classes')),
                                ..._c.classes.map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.name))),
                              ],
                              onChanged: (v) {
                                _c.filterClassId.value = v;
                                _c.filterSectionId.value = null;
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bLabel('Section'),
                        Obx(() => bDropdown<int?>(
                              hint: 'All',
                              value: _c.filterSectionId.value,
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('All Sections')),
                                ..._c.filteredSections.map((s) =>
                                    DropdownMenuItem(
                                        value: s.id, child: Text(s.name))),
                              ],
                              onChanged: (v) => _c.filterSectionId.value = v,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bLabel('Incident'),
                        Obx(() => bDropdown<int?>(
                              hint: 'All',
                              value: _c.filterIncidentId.value,
                              items: [
                                const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Incidents')),
                                ..._c.incidents.map((i) => DropdownMenuItem(
                                    value: i.id, child: Text(i.title))),
                              ],
                              onChanged: (v) => _c.filterIncidentId.value = v,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => bPrimaryBtn(
                          label: 'Apply',
                          loading: _c.isLoading.value,
                          onPressed: _c.applyFilters,
                        )),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _c.resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Reset', style: GoogleFonts.inter()),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Assignments list ──────────────────────────────────────────────
        Obx(() {
          if (_c.assignments.isEmpty) {
            return bEmptyState('No assignments found.',
                icon: Icons.assignment_outlined);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bSectionHeader(
                'Assignment Records',
                trailing: Text('${_c.assignments.length} records',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: kBehGray)),
              ),
              ..._c.assignments.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AssignmentCard(
                      key: ValueKey(a.id),
                      assignment: a,
                      onDelete: () => bDeleteDialog(
                        context,
                        'Delete this assignment record?',
                        () => _c.deleteAssignment(a.id),
                      ),
                      controller: _c,
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }
}

// ── Select class hint ─────────────────────────────────────────────────────────

class _SelectClassHint extends StatelessWidget {
  final int total;
  const _SelectClassHint({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBehPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBehPrimary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: kBehPrimary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a class to filter students',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kBehPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total student${total == 1 ? '' : 's'} available. '
                  'Choose a class above to narrow the list, '
                  'or tap "All" to select everyone.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Assignment Card ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatefulWidget {
  final AssignedIncident assignment;
  final VoidCallback onDelete;
  final BehaviourAssignmentController controller;

  const _AssignmentCard({
    super.key,
    required this.assignment,
    required this.onDelete,
    required this.controller,
  });

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  bool _showComments = false;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    final c = widget.controller;

    return Container(
      decoration: bCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main info row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: a.point < 0 ? kBehRed : kBehGreen,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.studentName.isNotEmpty
                                        ? a.studentName
                                        : 'Student #${a.student}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    a.incidentTitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: kBehPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            bPointBadge(a.point),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            bChip(Icons.calendar_today_outlined,
                                bFmtDate(a.createdAt), kBehBlue),
                            if (a.classId != null)
                              bChip(Icons.school_outlined,
                                  c.className(a.classId), kBehPrimary),
                            if (a.sectionId != null)
                              bChip(Icons.groups_outlined,
                                  c.sectionName(a.sectionId), kBehAmber),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _showComments = !_showComments),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: kBehPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.comment_outlined,
                                        size: 14, color: kBehPrimary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${a.comments.length} Comment${a.comments.length == 1 ? '' : 's'}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: kBehPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showComments
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 14,
                                      color: kBehPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            bActionBtn(Icons.delete_outline, kBehRed,
                                widget.onDelete),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Comments section
          if (_showComments)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  if (a.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('No comments yet.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: kBehGray)),
                    ),
                  ...a.comments.map((cm) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: kBehPrimary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cm.userName.isNotEmpty
                                        ? cm.userName[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: kBehPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    cm.userName.isNotEmpty
                                        ? cm.userName
                                        : 'Unknown',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF374151),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(bFmtDate(cm.createdAt),
                                    style: GoogleFonts.inter(
                                        fontSize: 10, color: kBehGray)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(cm.comment,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF374151))),
                          ],
                        ),
                      )),
                  // Add comment
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: GoogleFonts.inter(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Add a comment…',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: kBehGray),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: kBehPrimary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final text = _commentCtrl.text.trim();
                          await c.addComment(a.id, text);
                          _commentCtrl.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBehPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.send, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
