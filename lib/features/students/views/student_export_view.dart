import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_list_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentExportView extends StatefulWidget {
  const StudentExportView({super.key});
  @override
  State<StudentExportView> createState() => _StudentExportViewState();
}

class _StudentExportViewState extends State<StudentExportView> {
  // Reuse the StudentListController for data
  StudentListController get _c => Get.find<StudentListController>();

  // Export column selection
  final _selectedColumns = <String, bool>{
    'SL': true,
    'Admission No': true,
    'Roll No': true,
    'Name': true,
    'Class/Section': true,
    'Gender': true,
    'Date of Birth': true,
    'Status': true,
    'Category': false,
    'Guardian': false,
  }.obs;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Export Students',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentExport),
        Obx(() {
          if (_c.isLoading.value) {
            return const Expanded(child: SchoolLoader());
          }
          return Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildFilters(),
                const SizedBox(height: 16),
                _buildColumnSelector(),
                const SizedBox(height: 16),
                _buildPreviewAndExport(),
                const SizedBox(height: 40),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.filter_alt_rounded,
              color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          sectionHeader('Export Filters'),
        ]),
        const SizedBox(height: 14),
        sSearchBar(
          hint: 'Filter by name, admission no...',
          onChanged: (v) => _c.searchQuery.value = v,
        ),
        const SizedBox(height: 12),
        Obx(() => Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Class'),
                  const SizedBox(height: 6),
                  sDropdown<int>(
                    value: _c.filterClassId.value,
                    hint: 'All Classes',
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Classes')),
                      ..._c.classes.map((c) => DropdownMenuItem(
                          value: c['id'] as int,
                          child: Text(c['name'] as String? ?? ''))),
                    ],
                    onChanged: (v) {
                      _c.filterClassId.value = v;
                      _c.filterSectionId.value = null;
                    },
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Section'),
                  const SizedBox(height: 6),
                  sDropdown<int>(
                    value: _c.filterSectionId.value,
                    hint: 'All Sections',
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Sections')),
                      ..._c.sectionsForClass.map((s) => DropdownMenuItem(
                          value: s['id'] as int,
                          child: Text(s['name'] as String? ?? ''))),
                    ],
                    onChanged: (v) => _c.filterSectionId.value = v,
                  ),
                ],
              )),
            ])),
        const SizedBox(height: 10),
        Obx(() => Row(children: [
              Checkbox(
                value: _c.filterActiveOnly.value,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (v) =>
                    _c.filterActiveOnly.value = v ?? true,
              ),
              Text('Active students only',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF374151))),
            ])),
      ]),
    );
  }

  Widget _buildColumnSelector() {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.view_column_rounded,
              color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          sectionHeader('Export Columns'),
        ]),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedColumns.entries.map((e) {
                final selected = e.value;
                return FilterChip(
                  label: Text(e.key,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF6B7280))),
                  selected: selected,
                  onSelected: (v) => _selectedColumns[e.key] = v,
                  selectedColor:
                      const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFF4F46E5),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFD1D5DB),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            )),
      ]),
    );
  }

  Widget _buildPreviewAndExport() {
    return Obx(() {
      final items = _c.filtered;
      final activeCols = _selectedColumns.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      return Container(
        decoration: sCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // ── Header with gradient ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.preview_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827))),
                    Text('${items.length} records will be exported',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              // Record count badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${items.length}',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ]),
          ),

          // ── Export buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        items.isEmpty ? null : () => _exportCsv(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon:
                        const Icon(Icons.download_rounded, size: 18),
                    label: Text('CSV',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: items.isEmpty
                        ? null
                        : () => _showPrintPreview(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded,
                        size: 18),
                    label: Text('PDF',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ),
              ),
            ]),
          ),

          // ── Student preview cards ──
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: sEmptyState('No students match your filters',
                  Icons.person_off_rounded),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              itemCount: items.length > 10 ? 10 : items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _PreviewCard(
                index: i,
                student: items[i],
                columns: activeCols,
                controller: _c,
              ),
            ),
            if (items.length > 10)
              Padding(
                padding: const EdgeInsets.only(bottom: 14, top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      'Showing 10 of ${items.length} records',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1))),
                ),
              ),
          ],
        ]),
      );
    });
  }

  String _fieldValue(StudentRow s, String key, int index) {
    switch (key) {
      case 'SL':
        return '${index + 1}';
      case 'Admission No':
        return s.admissionNo;
      case 'Roll No':
        return s.rollNo ?? '—';
      case 'Name':
        return s.fullName;
      case 'Class/Section':
        return '${_c.className(s.currentClass)} / ${_c.sectionName(s.currentSection)}';
      case 'Gender':
        return s.genderLabel;
      case 'Date of Birth':
        return s.dateOfBirth ?? '—';
      case 'Status':
        return s.isActive ? 'Active' : 'Inactive';
      case 'Category':
        return _c.categoryName(s.category);
      case 'Guardian':
        return _c.guardianName(s.guardian);
      default:
        return '—';
    }
  }

  void _exportCsv(List<StudentRow> items) {
    // Build CSV content
    final buffer = StringBuffer();
    // Header
    final headers = _selectedColumns.entries
        .where((e) => e.value)
        .map((e) => '"${e.key}"')
        .join(',');
    buffer.writeln(headers);

    // Rows
    for (var i = 0; i < items.length; i++) {
      final s = items[i];
      final row = <String>[];
      _selectedColumns.forEach((key, selected) {
        if (!selected) return;
        switch (key) {
          case 'SL':
            row.add('"${i + 1}"');
            break;
          case 'Admission No':
            row.add('"${s.admissionNo}"');
            break;
          case 'Roll No':
            row.add('"${s.rollNo ?? ''}"');
            break;
          case 'Name':
            row.add('"${s.fullName}"');
            break;
          case 'Class/Section':
            row.add('"${_c.className(s.currentClass)} / ${_c.sectionName(s.currentSection)}"');
            break;
          case 'Gender':
            row.add('"${s.genderLabel}"');
            break;
          case 'Date of Birth':
            row.add('"${s.dateOfBirth ?? ''}"');
            break;
          case 'Status':
            row.add('"${s.isActive ? 'Active' : 'Inactive'}"');
            break;
          case 'Category':
            row.add('"${_c.categoryName(s.category)}"');
            break;
          case 'Guardian':
            row.add('"${_c.guardianName(s.guardian)}"');
            break;
        }
      });
      buffer.writeln(row.join(','));
    }

    Get.snackbar(
      'Export Ready',
      'CSV with ${items.length} records prepared. In a production build this would be saved to device.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  void _showPrintPreview(List<StudentRow> items) {
    Get.snackbar(
      'PDF Export',
      'PDF with ${items.length} records would open print dialog. Integrate the printing package for full PDF support.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CARD — responsive student card replacing the DataTable
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewCard extends StatelessWidget {
  final int index;
  final StudentRow student;
  final List<String> columns;
  final StudentListController controller;

  const _PreviewCard({
    required this.index,
    required this.student,
    required this.columns,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = student.isActive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top row: avatar + name + status ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                // Serial number circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.12),
                        const Color(0xFF7C3AED).withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6366F1))),
                ),
                const SizedBox(width: 10),
                // Name + admission no
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (columns.contains('Admission No'))
                        Text(student.admissionNo,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              const Color(0xFF22C55E)
                                  .withValues(alpha: 0.12),
                              const Color(0xFF22C55E)
                                  .withValues(alpha: 0.06),
                            ]
                          : [
                              const Color(0xFF6B7280)
                                  .withValues(alpha: 0.12),
                              const Color(0xFF6B7280)
                                  .withValues(alpha: 0.06),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isActive
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF6B7280))
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Detail chips (selected columns) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: columns
                  .where((c) =>
                      c != 'SL' &&
                      c != 'Name' &&
                      c != 'Admission No' &&
                      c != 'Status')
                  .map((col) => _DetailChip(
                        label: col,
                        value: _getValue(col),
                        icon: _getIcon(col),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getValue(String key) {
    switch (key) {
      case 'Roll No':
        return student.rollNo ?? '—';
      case 'Class/Section':
        return '${controller.className(student.currentClass)} / ${controller.sectionName(student.currentSection)}';
      case 'Gender':
        return student.genderLabel;
      case 'Date of Birth':
        return student.dateOfBirth ?? '—';
      case 'Category':
        return controller.categoryName(student.category);
      case 'Guardian':
        return controller.guardianName(student.guardian);
      default:
        return '—';
    }
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'Roll No':
        return Icons.tag_rounded;
      case 'Class/Section':
        return Icons.class_rounded;
      case 'Gender':
        return Icons.person_rounded;
      case 'Date of Birth':
        return Icons.cake_rounded;
      case 'Category':
        return Icons.category_rounded;
      case 'Guardian':
        return Icons.family_restroom_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
