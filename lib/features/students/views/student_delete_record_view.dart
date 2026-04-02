import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_delete_record_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentDeleteRecordView extends StatefulWidget {
  const StudentDeleteRecordView({super.key});
  @override
  State<StudentDeleteRecordView> createState() =>
      _StudentDeleteRecordViewState();
}

class _StudentDeleteRecordViewState extends State<StudentDeleteRecordView> {
  StudentDeleteRecordController get _c =>
      Get.find<StudentDeleteRecordController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Delete Records',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentDeleteRecord),
        _buildTabs(),
        _buildFilters(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildTabs() {
    return Obx(() => Container(
          color: Colors.white,
          child: Row(children: [
            _TabBtn(
              label: 'Active Students',
              count: _c.allStudents.where((s) => s.isActive && !s.isDisabled).length,
              isActive: _c.activeTab.value == 0,
              color: const Color(0xFF16A34A),
              onTap: () => _c.activeTab.value = 0,
            ),
            _TabBtn(
              label: 'Deleted Records',
              count: _c.allStudents.where((s) => !s.isActive).length,
              isActive: _c.activeTab.value == 1,
              color: const Color(0xFFDC2626),
              onTap: () => _c.activeTab.value = 1,
            ),
          ]),
        ));
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(children: [
        sSearchBar(
          hint: 'Search by name or admission no...',
          onChanged: (v) => _c.searchQuery.value = v,
        ),
        const SizedBox(height: 8),
        Obx(() => Row(children: [
              Expanded(child: _SmallDropdown<int?>(
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
              )),
              const SizedBox(width: 10),
              Expanded(child: _SmallDropdown<int?>(
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
              )),
            ])),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const SchoolLoader();
      }
      final items = _c.filtered;
      final isDeletedTab = _c.activeTab.value == 1;
      if (items.isEmpty) {
        return sEmptyState(
            isDeletedTab
                ? 'No deleted records found.'
                : 'No active students found.',
            isDeletedTab
                ? Icons.delete_outline_rounded
                : Icons.people_outline_rounded);
      }
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadAll,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final s = items[i];
            return isDeletedTab
                ? _DeletedCard(
                    student: s,
                    className: _c.className(s.currentClass),
                    sectionName: _c.sectionName(s.currentSection),
                    guardianName: _c.guardianName(s.guardian),
                    onRestore: () => _confirmRestore(s),
                    onPermanentDelete: () => _confirmPermanentDelete(s),
                  )
                : _ActiveCard(
                    student: s,
                    className: _c.className(s.currentClass),
                    sectionName: _c.sectionName(s.currentSection),
                    guardianName: _c.guardianName(s.guardian),
                    onDelete: () => _confirmSoftDelete(s),
                  );
          },
        ),
      );
    });
  }

  void _confirmSoftDelete(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sDeleteDialog(
        context: context,
        message:
            'Move "${s.fullName}" to deleted records? They can be restored later.',
        onConfirm: () => _c.softDelete(s.id),
      ),
    );
  }

  void _confirmRestore(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sConfirmDialog(
        context: context,
        title: 'Restore Student',
        message: 'Restore "${s.fullName}" to active students?',
        confirmLabel: 'Restore',
        confirmColor: const Color(0xFF16A34A),
        onConfirm: () => _c.restore(s.id),
      ),
    );
  }

  void _confirmPermanentDelete(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sDeleteDialog(
        context: context,
        message:
            'PERMANENTLY delete "${s.fullName}"? This action cannot be undone!',
        onConfirm: () => _c.permanentDelete(s.id),
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.count,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: isActive ? color : Colors.transparent, width: 2),
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                      color: isActive ? color : const Color(0xFF6B7280))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive ? color : Colors.grey)),
              ),
            ]),
          ),
        ),
      );
}

// ── Active card ───────────────────────────────────────────────────────────────

class _ActiveCard extends StatelessWidget {
  final StudentRow student;
  final String className;
  final String sectionName;
  final String guardianName;
  final VoidCallback onDelete;

  const _ActiveCard({
    required this.student,
    required this.className,
    required this.sectionName,
    required this.guardianName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: sCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFF16A34A).withValues(alpha: 0.1),
          child: Text(
            student.firstName.isNotEmpty
                ? student.firstName[0].toUpperCase()
                : '?',
            style: GoogleFonts.inter(
                color: const Color(0xFF16A34A),
                fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(student.fullName,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adm: ${student.admissionNo}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
              if (className != '—')
                Text('$className / $sectionName',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF4F46E5))),
            ]),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFDC2626), size: 22),
          onPressed: onDelete,
          tooltip: 'Move to Deleted',
        ),
      ),
    );
  }
}

// ── Deleted card ──────────────────────────────────────────────────────────────

class _DeletedCard extends StatelessWidget {
  final StudentRow student;
  final String className;
  final String sectionName;
  final String guardianName;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const _DeletedCard({
    required this.student,
    required this.className,
    required this.sectionName,
    required this.guardianName,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFCA5A5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor:
                  const Color(0xFFDC2626).withValues(alpha: 0.1),
              child: Text(
                student.firstName.isNotEmpty
                    ? student.firstName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF111827))),
                Text('Adm: ${student.admissionNo}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF6B7280))),
              ],
            )),
            sBadge('Deleted', const Color(0xFFDC2626)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: onRestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: Text('Restore',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: onPermanentDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.delete_forever_rounded, size: 16),
              label: Text('Perm. Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _SmallDropdown<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SmallDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF9CA3AF))),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
          style: GoogleFonts.inter(
              fontSize: 13, color: const Color(0xFF111827)),
          iconSize: 18,
        ),
      );
}
