import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_record_card.dart';
import '../widgets/admin_form_sheet.dart';

class VisitorBookView extends StatefulWidget {
  const VisitorBookView({super.key});
  @override
  State<VisitorBookView> createState() => _VisitorBookViewState();
}

class _VisitorBookViewState extends State<VisitorBookView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook, isActive: true),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint),
    const AdminTabItem(label: 'Postal Receive', route: AppRoutes.adminPostalReceive),
    const AdminTabItem(label: 'Postal Dispatch', route: AppRoutes.adminPostalDispatch),
    const AdminTabItem(label: 'Phone Call Log', route: AppRoutes.adminPhoneCallLog),
    const AdminTabItem(label: 'Admin Setup', route: AppRoutes.adminSetup),
    const AdminTabItem(label: 'ID Card', route: AppRoutes.adminIdCard),
    const AdminTabItem(label: 'Certificate', route: AppRoutes.adminCertificate),
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard),
  ];

  @override
  void initState() {
    super.initState();
    _c.loadVisitors();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Visitor Book',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search visitors...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _c.resetVisitorForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Visitor'),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value)
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)));
      final items = _c.filteredVisitors;
      if (items.isEmpty)
        return _empty('No visitor records yet.\nTap + to add the first entry.',
            _c.loadVisitors);
      return RefreshIndicator(
        color: const Color(0xFF6366F1),
        onRefresh: _c.loadVisitors,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final v = items[i];
            return AdminRecordCard(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF6366F1),
              title: v.name,
              subtitle:
                  '${v.purpose} · ${v.date}  In: ${v.inTime}  Out: ${v.outTime}',
              onEdit: () {
                _c.startEditVisitor(v);
                _showForm(context);
              },
              onDelete: () => _confirmDelete(
                  'Delete visitor "${v.name}"?', () => _c.deleteVisitor(v.id)),
              extraBadges: [
                _badge('${v.noOfPerson} person(s)', const Color(0xFF6B7280)),
                if (v.phone.isNotEmpty)
                  _badge(v.phone, const Color(0xFF0EA5E9)),
              ],
            );
          },
        ),
      );
    });
  }

  void _showForm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _FormSheet(
        title: _c.editingId.value != null ? 'Edit Visitor' : 'Add Visitor',
        onClose: () {
          _c.resetVisitorForm();
          Navigator.pop(sheetCtx);
        },
        child: Column(children: [
          _section('Visitor Info'),
          AdminField(
              controller: _c.visitorNameCtrl,
              label: 'Full Name',
              required: true),
          AdminField(
              controller: _c.visitorPhoneCtrl,
              label: 'Phone',
              keyboardType: TextInputType.phone),
          AdminField(
              controller: _c.visitorIdCtrl,
              label: 'Visitor ID',
              required: true),
          AdminField(
              controller: _c.noOfPersonCtrl,
              label: 'No. of Persons',
              keyboardType: TextInputType.number),
          _section('Visit Details'),
          AdminField(
              controller: _c.purposeCtrl, label: 'Purpose', required: true),
          AdminField(
              controller: _c.visitorDateCtrl,
              label: 'Visit Date (YYYY-MM-DD)',
              required: true),
          AdminField(
              controller: _c.inTimeCtrl,
              label: 'In Time (e.g. 10:00)',
              required: true),
          AdminField(
              controller: _c.outTimeCtrl,
              label: 'Out Time (e.g. 11:30)',
              required: true),
          const SizedBox(height: 8),
          Obx(() => _actionRow(
                isSaving: _c.isSaving.value,
                isEditing: _c.editingId.value != null,
                onSave: () async {
                  await _c.saveVisitor();
                  if (!_c.isSaving.value && sheetCtx.mounted)
                    Navigator.pop(sheetCtx);
                },
                onCancel: () {
                  _c.resetVisitorForm();
                  Navigator.pop(sheetCtx);
                },
              )),
        ]),
      ),
    );
  }

  // ── shared helpers ────────────────────────────────────────────────────────

  void _confirmDelete(String msg, VoidCallback fn) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  fn();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white),
                child: const Text('Delete')),
          ],
        ),
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _empty(String msg, VoidCallback onRefresh) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(msg,
              style: GoogleFonts.inter(color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh')),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared private form-sheet wrapper + helpers used by every view in this file
// ═══════════════════════════════════════════════════════════════════════════

class _FormSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;
  const _FormSheet(
      {required this.title, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
            child: Row(children: [
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827)))),
              IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                  onPressed: onClose),
            ]),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: child,
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _section(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6366F1),
              letterSpacing: 0.5)),
    );

Widget _actionRow({
  required bool isSaving,
  required bool isEditing,
  required VoidCallback onSave,
  required VoidCallback onCancel,
}) =>
    Row(children: [
      if (isEditing) ...[
        Expanded(
            child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: Text('Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        )),
        const SizedBox(width: 12),
      ],
      Expanded(
          child: ElevatedButton(
        onPressed: isSaving ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(isEditing ? 'Update' : 'Save',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      )),
    ]);
