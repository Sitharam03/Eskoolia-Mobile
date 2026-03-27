import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
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
            return const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4F46E5))));
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
      return Container(
        decoration: sCardDecoration,
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader('Preview'),
                  Text('${items.length} records will be exported',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280))),
                ],
              )),
            ]),
          ),
          // Export buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: items.isEmpty ? null : () => _exportCsv(items),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text('Export CSV',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: items.isEmpty ? null : () => _showPrintPreview(items),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: Text('Export PDF',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
          // Preview table
          if (items.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF9FAFB)),
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 52,
                    columnSpacing: 24,
                    headingTextStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFF374151)),
                    dataTextStyle: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF111827)),
                    columns: _buildColumns(),
                    rows: _buildRows(items.take(10).toList()),
                  ),
                ),
              ),
            ),
          if (items.length > 10)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text('Showing first 10 of ${items.length} records',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ),
        ]),
      );
    });
  }

  List<DataColumn> _buildColumns() {
    final cols = <DataColumn>[];
    _selectedColumns.forEach((key, selected) {
      if (selected) cols.add(DataColumn(label: Text(key)));
    });
    return cols.isEmpty ? [const DataColumn(label: Text('Name'))] : cols;
  }

  List<DataRow> _buildRows(List<StudentRow> items) {
    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final cells = <DataCell>[];

      _selectedColumns.forEach((key, selected) {
        if (!selected) return;
        switch (key) {
          case 'SL':
            cells.add(DataCell(Text('${i + 1}')));
            break;
          case 'Admission No':
            cells.add(DataCell(Text(s.admissionNo)));
            break;
          case 'Roll No':
            cells.add(DataCell(Text(s.rollNo ?? '—')));
            break;
          case 'Name':
            cells.add(DataCell(Text(s.fullName)));
            break;
          case 'Class/Section':
            cells.add(DataCell(Text(
                '${_c.className(s.currentClass)} / ${_c.sectionName(s.currentSection)}')));
            break;
          case 'Gender':
            cells.add(DataCell(Text(s.genderLabel)));
            break;
          case 'Date of Birth':
            cells.add(DataCell(Text(s.dateOfBirth ?? '—')));
            break;
          case 'Status':
            cells.add(DataCell(Text(s.isActive ? 'Active' : 'Inactive')));
            break;
          case 'Category':
            cells.add(DataCell(Text(_c.categoryName(s.category))));
            break;
          case 'Guardian':
            cells.add(DataCell(Text(_c.guardianName(s.guardian))));
            break;
          default:
            cells.add(const DataCell(Text('—')));
        }
      });
      return DataRow(cells: cells.isEmpty ? [const DataCell(Text(''))] : cells);
    }).toList();
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
