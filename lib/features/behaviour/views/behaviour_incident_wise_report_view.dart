import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_settings_controller.dart';
import '../models/behaviour_models.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';
import '../../../core/widgets/school_loader.dart';

class BehaviourIncidentWiseReportView extends StatelessWidget {
  const BehaviourIncidentWiseReportView({super.key});

  BehaviourSettingsController get _c =>
      Get.find<BehaviourSettingsController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(
              activeRoute: AppRoutes.behaviourIncidentWiseReport),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadIncidentWiseReport,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterBox(),
                      const SizedBox(height: 16),
                      _buildResults(),
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

  Widget _buildFilterBox() {
    return bFilterBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bSectionHeader('Incident Wise Report'),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bLabel('Year'),
                    Obx(() => bDropdown<int?>(
                          hint: 'Any Year',
                          value: _c.reportYearId.value,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Any Year')),
                            ..._c.academicYears.map((y) => DropdownMenuItem(
                                value: y.id, child: Text(y.title))),
                          ],
                          onChanged: (v) => _c.reportYearId.value = v,
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
                          hint: 'All Classes',
                          value: _c.reportClassId.value,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Classes')),
                            ..._c.classes.map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (v) {
                            _c.reportClassId.value = v;
                            _c.reportSectionId.value = null;
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bLabel('Section'),
              Obx(() => bDropdown<int?>(
                    hint: 'All Sections',
                    value: _c.reportSectionId.value,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Sections')),
                      ..._c.filteredSections.map((s) => DropdownMenuItem(
                          value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => _c.reportSectionId.value = v,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => bPrimaryBtn(
                      label: 'Run Report',
                      loading: _c.reportLoading.value,
                      onPressed: _c.loadIncidentWiseReport,
                      icon: Icons.analytics_outlined,
                    )),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  _c.resetReportFilters();
                  _c.incidentWiseRows.clear();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Reset', style: GoogleFonts.inter()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (_c.reportLoading.value) {
        return const SchoolLoader();
      }
      if (_c.incidentWiseRows.isEmpty) {
        return bEmptyState(
          'Run the report to see incidents with student breakdown.',
          icon: Icons.analytics_outlined,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bSectionHeader(
            'Incidents',
            trailing: Text('${_c.incidentWiseRows.length} incidents',
                style: GoogleFonts.inter(fontSize: 12, color: kBehGray)),
          ),
          ..._c.incidentWiseRows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IncidentWiseCard(row: row),
              )),
        ],
      );
    });
  }
}

// ── Incident Wise Card ───────────────────────────────────────────────────────

class _IncidentWiseCard extends StatefulWidget {
  final IncidentWiseRow row;
  const _IncidentWiseCard({required this.row});

  @override
  State<_IncidentWiseCard> createState() => _IncidentWiseCardState();
}

class _IncidentWiseCardState extends State<_IncidentWiseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final ptColor = row.totalPoints >= 0 ? kBehGreen : kBehRed;

    return Container(
      decoration: bCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (row.students.isNotEmpty) {
                setState(() => _expanded = !_expanded);
              }
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: ptColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  row.incidentTitle.isNotEmpty
                                      ? row.incidentTitle
                                      : 'Incident #${row.incidentId}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              bPointBadge(row.totalPoints),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              bChip(
                                Icons.assignment_outlined,
                                '${row.assignmentCount} assignments',
                                kBehPrimary,
                              ),
                              bChip(
                                Icons.people_outline,
                                '${row.students.length} students',
                                kBehBlue,
                              ),
                            ],
                          ),
                          if (row.students.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    _expanded
                                        ? 'Hide students'
                                        : 'View ${row.students.length} student${row.students.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: kBehPrimary,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _expanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: kBehPrimary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Student breakdown
          if (_expanded && row.students.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: row.students.asMap().entries.map((e) {
                  final isLast = e.key == row.students.length - 1;
                  final student = e.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.studentName.isNotEmpty
                                ? student.studentName
                                : 'Student #${student.studentId}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        bPointBadge(student.point),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
