import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_multi_class_controller.dart';
import '../models/multi_class_record_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentMultiClassView extends StatefulWidget {
  const StudentMultiClassView({super.key});
  @override
  State<StudentMultiClassView> createState() => _StudentMultiClassViewState();
}

class _StudentMultiClassViewState extends State<StudentMultiClassView> {
  StudentMultiClassController get _c =>
      Get.find<StudentMultiClassController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Multi-Class Assignment',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return Column(children: [
            const StudentNavTabs(activeRoute: AppRoutes.studentMultiClass),
            Expanded(
              child: Obx(() {
                if (_c.isLoading.value) {
                  return const SchoolLoader();
                }
                if (isWide) {
                  return Row(children: [
                    SizedBox(width: 300, child: _buildStudentPanel()),
                    Expanded(child: _buildRecordsPanel()),
                  ]);
                }
                return _c.selectedStudent.value != null
                    ? _buildRecordsPanel()
                    : _buildStudentPanel();
              }),
            ),
          ]);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STUDENT LIST PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStudentPanel() {
    return Obx(() {
      final isNarrow = MediaQuery.of(context).size.width < 600;
      if (isNarrow && _c.selectedStudent.value != null) {
        return _buildRecordsPanel();
      }
      return Container(
        decoration: isNarrow
            ? null
            : BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.08)))),
        child: Column(children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFF6366F1).withValues(alpha: 0.03),
                ],
              ),
            ),
            child: sSearchBar(
              hint: 'Search students...',
              onChanged: (v) => _c.searchQuery.value = v,
            ),
          ),
          Expanded(
            child: _c.filteredStudents.isEmpty
                ? sEmptyState('No students found', Icons.people_outline)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    itemCount: _c.filteredStudents.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final s = _c.filteredStudents[i];
                      final isSelected =
                          _c.selectedStudent.value?.id == s.id;
                      return GestureDetector(
                        onTap: () => _c.selectStudent(s),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF7C3AED)
                                      ])
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Colors.white,
                                        const Color(0xFF6366F1)
                                            .withValues(alpha: 0.03),
                                      ]),
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.08)),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ],
                          ),
                          child: Row(children: [
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [
                                        Colors.white
                                            .withValues(alpha: 0.25),
                                        Colors.white
                                            .withValues(alpha: 0.15),
                                      ])
                                    : LinearGradient(colors: [
                                        const Color(0xFF6366F1)
                                            .withValues(alpha: 0.12),
                                        const Color(0xFF7C3AED)
                                            .withValues(alpha: 0.06),
                                      ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                s.firstName.isNotEmpty
                                    ? s.firstName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF6366F1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(s.fullName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF111827),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text('Adm: ${s.admissionNo}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white
                                                .withValues(alpha: 0.7)
                                            : const Color(0xFF6B7280),
                                      )),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                      .withValues(alpha: 0.7)
                                  : const Color(0xFF6366F1)
                                      .withValues(alpha: 0.3),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RECORDS PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRecordsPanel() {
    return Obx(() {
      final student = _c.selectedStudent.value;
      if (student == null) {
        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.10),
                        const Color(0xFF7C3AED).withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_search_rounded,
                      size: 32,
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: 0.4)),
                ),
                const SizedBox(height: 14),
                Text('Select a student',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFF374151))),
                const SizedBox(height: 4),
                Text('to manage their class assignments',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF9CA3AF), fontSize: 13)),
              ]),
        );
      }

      return Column(children: [
        // ── Student header ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.08),
                const Color(0xFF7C3AED).withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Row(children: [
            if (MediaQuery.of(context).size.width < 600)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _c.clearSelection,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF6366F1), size: 18),
                  ),
                ),
              ),
            // Student avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                student.firstName.isNotEmpty
                    ? student.firstName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF111827))),
                  Text('Adm: ${student.admissionNo}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280))),
                ],
              ),
            ),
          ]),
        ),

        // ── Records list ──
        Expanded(
          child: _c.isLoadingRecords.value
              ? const SchoolLoader()
              : _buildRecordsList(),
        ),

        // ── Save bar ──
        _buildSaveBar(),
      ]);
    });
  }

  Widget _buildRecordsList() {
    return Obx(() => Column(children: [
          // Add record button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        const Color(0xFF6366F1).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: OutlinedButton.icon(
                  onPressed: _c.addRecord,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add_rounded,
                        size: 14, color: Colors.white),
                  ),
                  label: Text('Add Class Record',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
          ),
          if (_c.records.isEmpty)
            Expanded(
                child: sEmptyState(
                    'No class records.\nTap "Add Class Record" to begin.',
                    Icons.class_outlined))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _c.records.length,
                itemBuilder: (_, i) => _RecordCard(
                  index: i,
                  record: _c.records[i],
                  classes: _c.classes,
                  allSections: _c.sections,
                  onUpdate: (updated) => _c.updateRecord(i, updated),
                  onSetDefault: () => _c.setDefault(i),
                  onRemove: () => _c.removeRecord(i),
                ),
              ),
            ),
        ]));
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFF6366F1).withValues(alpha: 0.03),
          ],
        ),
        border: Border(
            top: BorderSide(
                color:
                    const Color(0xFF6366F1).withValues(alpha: 0.08))),
      ),
      child: Obx(() => SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    _c.isSaving.value ? null : _c.saveRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _c.isSaving.value
                    ? sSavingIndicator()
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text('Save All Records',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600)),
              ),
            ),
          )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECORD CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _RecordCard extends StatelessWidget {
  final int index;
  final MultiClassRecord record;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> allSections;
  final ValueChanged<MultiClassRecord> onUpdate;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  const _RecordCard({
    required this.index,
    required this.record,
    required this.classes,
    required this.allSections,
    required this.onUpdate,
    required this.onSetDefault,
    required this.onRemove,
  });

  List<Map<String, dynamic>> get _sections => record.schoolClass == 0
      ? allSections
      : allSections
          .where((s) => s['school_class'] == record.schoolClass)
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            record.isDefault
                ? const Color(0xFF22C55E).withValues(alpha: 0.04)
                : const Color(0xFF6366F1).withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: record.isDefault
              ? const Color(0xFF22C55E).withValues(alpha: 0.2)
              : const Color(0xFF6366F1).withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: (record.isDefault
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF6366F1))
                .withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: [
        // ── Header row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
          child: Row(children: [
            // Record number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: record.isDefault
                      ? [
                          const Color(0xFF22C55E),
                          const Color(0xFF16A34A)
                        ]
                      : [
                          const Color(0xFF6366F1).withValues(alpha: 0.12),
                          const Color(0xFF7C3AED).withValues(alpha: 0.06),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: record.isDefault
                          ? Colors.white
                          : const Color(0xFF6366F1))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Class Record',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF111827))),
            ),
            if (record.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22C55E).withValues(alpha: 0.12),
                      const Color(0xFF22C55E).withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF22C55E)
                          .withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 3),
                    Text('Default',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A))),
                  ],
                ),
              )
            else
              TextButton(
                onPressed: onSetDefault,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                ),
                child: Text('Set Default',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1))),
              ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFDC2626).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFFDC2626)),
              ),
            ),
          ]),
        ),

        // ── Dropdowns ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Class'),
                  const SizedBox(height: 4),
                  sDropdown<int>(
                    value: record.schoolClass == 0
                        ? null
                        : record.schoolClass,
                    hint: 'Select class',
                    items: classes
                        .map((c) => DropdownMenuItem(
                            value: c['id'] as int,
                            child:
                                Text(c['name'] as String? ?? '')))
                        .toList(),
                    onChanged: (v) => onUpdate(record.copyWith(
                        schoolClass: v ?? 0, section: null)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Section'),
                  const SizedBox(height: 4),
                  sDropdown<int>(
                    value: record.section,
                    hint: 'Section',
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('None')),
                      ..._sections.map((s) => DropdownMenuItem(
                          value: s['id'] as int,
                          child:
                              Text(s['name'] as String? ?? ''))),
                    ],
                    onChanged: (v) =>
                        onUpdate(record.copyWith(section: v)),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
