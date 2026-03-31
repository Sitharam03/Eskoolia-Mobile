import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_settings_controller.dart';
import '../models/behaviour_models.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';

class BehaviourStudentIncidentReportView extends StatelessWidget {
  const BehaviourStudentIncidentReportView({super.key});

  BehaviourSettingsController get _c =>
      Get.find<BehaviourSettingsController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(
              activeRoute: AppRoutes.behaviourStudentIncidentReport),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: _c.loadStudentIncidentReport,
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
          bSectionHeader('Student Incident Report'),
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
          Row(
            children: [
              Expanded(
                child: Column(
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
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bLabel('Student Name'),
                    bTextField(_c.reportNameCtrl, 'Search name'),
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
                      label: 'Run Report',
                      loading: _c.reportLoading.value,
                      onPressed: _c.loadStudentIncidentReport,
                      icon: Icons.bar_chart,
                    )),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  _c.resetReportFilters();
                  _c.incidentReportRows.clear();
                },
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
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (_c.reportLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_c.incidentReportRows.isEmpty) {
        return bEmptyState(
          'Run the report to see student incident data.',
          icon: Icons.people_outline,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bSectionHeader(
            'Results',
            trailing: Text('${_c.incidentReportRows.length} students',
                style: GoogleFonts.inter(fontSize: 12, color: kBehGray)),
          ),
          ..._c.incidentReportRows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StudentIncidentCard(row: row, c: _c),
              )),
        ],
      );
    });
  }
}

// ── Student Incident Card ─────────────────────────────────────────────────────

class _StudentIncidentCard extends StatefulWidget {
  final StudentIncidentReportRow row;
  final BehaviourSettingsController c;
  const _StudentIncidentCard({required this.row, required this.c});

  @override
  State<_StudentIncidentCard> createState() => _StudentIncidentCardState();
}

class _StudentIncidentCardState extends State<_StudentIncidentCard> {
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
            onTap: () => setState(() => _expanded = !_expanded),
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      row.studentName.isNotEmpty
                                          ? row.studentName
                                          : 'Student #${row.studentId}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (row.admissionNo.isNotEmpty)
                                      Text(row.admissionNo,
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: kBehGray)),
                                  ],
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
                              bChip(Icons.warning_amber_outlined,
                                  '${row.totalIncidents} incidents',
                                  kBehAmber),
                              if (row.classId != null)
                                bChip(Icons.school_outlined,
                                    widget.c.className(row.classId),
                                    kBehPrimary),
                              if (row.sectionId != null)
                                bChip(Icons.groups_outlined,
                                    widget.c.sectionName(row.sectionId),
                                    kBehBlue),
                            ],
                          ),
                          if (row.incidents.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    _expanded
                                        ? 'Hide incidents'
                                        : 'View ${row.incidents.length} incident${row.incidents.length == 1 ? '' : 's'}',
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
          // Incident breakdown
          if (_expanded && row.incidents.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: row.incidents.asMap().entries.map((e) {
                  final isLast = e.key == row.incidents.length - 1;
                  final item = e.value;
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.incident,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                bFmtDate(item.createdAt),
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: kBehGray),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        bPointBadge(item.point),
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
