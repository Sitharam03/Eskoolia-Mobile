import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_settings_controller.dart';
import '../models/behaviour_models.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';

class BehaviourStudentRankReportView extends StatelessWidget {
  const BehaviourStudentRankReportView({super.key});

  BehaviourSettingsController get _c =>
      Get.find<BehaviourSettingsController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(
              activeRoute: AppRoutes.behaviourStudentRankReport),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: _c.loadStudentRankReport,
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
          bSectionHeader('Student Behaviour Rank Report'),
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
          const SizedBox(height: 8),
          // Point threshold row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bLabel('Point Threshold'),
                    bTextField(
                      _c.rankPointCtrl,
                      'e.g. 10',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bLabel('Operator'),
                    Obx(() => bDropdown<String>(
                          hint: 'Select',
                          value: _c.rankOperator.value,
                          items: const [
                            DropdownMenuItem(
                                value: 'above', child: Text('Above')),
                            DropdownMenuItem(
                                value: 'below', child: Text('Below')),
                          ],
                          onChanged: (v) {
                            if (v != null) _c.rankOperator.value = v;
                          },
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
                      label: 'Run Report',
                      loading: _c.reportLoading.value,
                      onPressed: _c.loadStudentRankReport,
                      icon: Icons.leaderboard,
                    )),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  _c.resetReportFilters();
                  _c.rankRows.clear();
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
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_c.rankRows.isEmpty) {
        return bEmptyState(
          'Run the report to see student behaviour rankings.',
          icon: Icons.leaderboard_outlined,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bSectionHeader(
            'Rankings',
            trailing: Text('${_c.rankRows.length} students',
                style: GoogleFonts.inter(fontSize: 12, color: kBehGray)),
          ),
          ..._c.rankRows.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RankCard(rank: e.key + 1, row: e.value, c: _c),
              )),
        ],
      );
    });
  }
}

// ── Rank Card ────────────────────────────────────────────────────────────────

class _RankCard extends StatelessWidget {
  final int rank;
  final StudentRankRow row;
  final BehaviourSettingsController c;

  const _RankCard(
      {required this.rank, required this.row, required this.c});

  @override
  Widget build(BuildContext context) {
    final ptColor = row.totalPoints >= 0 ? kBehGreen : kBehRed;

    return Container(
      decoration: bCardDecoration(),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    bRankBadge(rank),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 11, color: kBehGray)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              bChip(Icons.warning_amber_outlined,
                                  '${row.totalIncidents} incidents',
                                  kBehAmber),
                              if (row.classId != null)
                                bChip(Icons.school_outlined,
                                    c.className(row.classId), kBehPrimary),
                              if (row.sectionId != null)
                                bChip(Icons.groups_outlined,
                                    c.sectionName(row.sectionId), kBehBlue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    bPointBadge(row.totalPoints),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
