import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
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
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5)));
                }
                if (isWide) {
                  return Row(children: [
                    SizedBox(width: 300, child: _buildStudentPanel()),
                    Expanded(child: _buildRecordsPanel()),
                  ]);
                }
                // Narrow: show student list OR record panel
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

  Widget _buildStudentPanel() {
    return Obx(() {
      final isNarrow = MediaQuery.of(context).size.width < 600;
      if (isNarrow && _c.selectedStudent.value != null) {
        return _buildRecordsPanel();
      }
      return Container(
        decoration: isNarrow
            ? null
            : const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: sSearchBar(
              hint: 'Search students...',
              onChanged: (v) => _c.searchQuery.value = v,
            ),
          ),
          Expanded(
            child: _c.filteredStudents.isEmpty
                ? sEmptyState('No students found', Icons.people_outline)
                : ListView.builder(
                    itemCount: _c.filteredStudents.length,
                    itemBuilder: (_, i) {
                      final s = _c.filteredStudents[i];
                      final isSelected =
                          _c.selectedStudent.value?.id == s.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        selected: isSelected,
                        selectedTileColor:
                            const Color(0xFF4F46E5).withValues(alpha: 0.06),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE5E7EB),
                          child: Text(
                            s.firstName.isNotEmpty
                                ? s.firstName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(s.fullName,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xFF111827))),
                        subtitle: Text('Adm: ${s.admissionNo}',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF6B7280))),
                        onTap: () => _c.selectStudent(s),
                        trailing: isSelected
                            ? const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF4F46E5))
                            : null,
                      );
                    },
                  ),
          ),
        ]),
      );
    });
  }

  Widget _buildRecordsPanel() {
    return Obx(() {
      final student = _c.selectedStudent.value;
      if (student == null) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.arrow_back_rounded,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Select a student to manage\ntheir class assignments',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.grey.shade500, fontSize: 14)),
          ]),
        );
      }
      return Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          color: const Color(0xFFF5F3FF),
          child: Row(children: [
            if (MediaQuery.of(context).size.width < 600)
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF4F46E5)),
                onPressed: _c.clearSelection,
              ),
            CircleAvatar(
              backgroundColor: const Color(0xFF4F46E5),
              child: Text(
                student.firstName.isNotEmpty
                    ? student.firstName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(student.fullName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF111827))),
                  Text('Adm: ${student.admissionNo}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280))),
                ])),
          ]),
        ),
        Expanded(
          child: _c.isLoadingRecords.value
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF4F46E5)))
              : _buildRecordsList(),
        ),
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
              child: OutlinedButton.icon(
                onPressed: _c.addRecord,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add Class Record',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
                itemBuilder: (_, i) => _RecordRow(
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _c.isSaving.value ? null : _c.saveRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: _c.isSaving.value
                  ? sSavingIndicator()
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text('Save All Records',
                  style:
                      GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          )),
    );
  }
}

// ── Record row widget ─────────────────────────────────────────────────────────

class _RecordRow extends StatelessWidget {
  final int index;
  final MultiClassRecord record;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> allSections;
  final ValueChanged<MultiClassRecord> onUpdate;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  const _RecordRow({
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
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text('#${index + 1} Class Record',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF111827))),
          ),
          if (record.isDefault)
            sBadge('Default', const Color(0xFF16A34A))
          else
            TextButton(
              onPressed: onSetDefault,
              child: Text('Set Default',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF4F46E5))),
            ),
          sIconBtn(
              Icons.delete_outline_rounded, const Color(0xFFDC2626), onRemove),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: sDropdown<int>(
            value: record.schoolClass == 0 ? null : record.schoolClass,
            hint: 'Select class',
            items: classes
                .map((c) => DropdownMenuItem(
                    value: c['id'] as int,
                    child: Text(c['name'] as String? ?? '')))
                .toList(),
            onChanged: (v) => onUpdate(record.copyWith(
                schoolClass: v ?? 0, section: null)),
          )),
          const SizedBox(width: 10),
          Expanded(child: sDropdown<int>(
            value: record.section,
            hint: 'Section',
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ..._sections.map((s) => DropdownMenuItem(
                  value: s['id'] as int,
                  child: Text(s['name'] as String? ?? ''))),
            ],
            onChanged: (v) => onUpdate(record.copyWith(section: v)),
          )),
        ]),
      ]),
    );
  }
}
