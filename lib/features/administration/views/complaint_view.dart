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

class ComplaintView extends StatefulWidget {
  const ComplaintView({super.key});
  @override
  State<ComplaintView> createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint, isActive: true),
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
    _c.loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Complaint',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search complaints...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _c.resetComplaintForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Complaint'),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value)
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      final items = _c.filteredComplaints;
      if (items.isEmpty)
        return _empty(
            'No complaints found.\nTap + to file the first complaint.',
            _c.loadComplaints,
            Icons.report_gmailerrorred_outlined);
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadComplaints,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final c = items[i];
            return AdminRecordCard(
              icon: Icons.report_outlined,
              iconColor: const Color(0xFFEF4444),
              title: c.complaintBy,
              subtitle:
                  '${c.complaintType} · ${c.complaintSource}${c.date.isNotEmpty ? ' · ${c.date}' : ''}',
              onEdit: () {
                _c.startEditComplaint(c);
                _showForm(context);
              },
              onDelete: () => _confirmDelete(
                  'Delete complaint by "${c.complaintBy}"?',
                  () => _c.deleteComplaint(c.id)),
              extraBadges: [
                if (c.assigned.isNotEmpty)
                  _badge('Assigned: ${c.assigned}', const Color(0xFF7C3AED)),
                if (c.phone.isNotEmpty)
                  _badge(c.phone, const Color(0xFF6B7280)),
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
        title: _c.editingId.value != null ? 'Edit Complaint' : 'Add Complaint',
        onClose: () {
          _c.resetComplaintForm();
          Navigator.pop(sheetCtx);
        },
        child: Column(children: [
          _section('Complainant Info'),
          AdminField(
              controller: _c.complaintByCtrl,
              label: 'Complaint By',
              required: true),
          AdminField(
              controller: _c.complaintPhoneCtrl,
              label: 'Phone',
              keyboardType: TextInputType.phone),
          _section('Complaint Details'),
          AdminField(
              controller: _c.complaintTypeCtrl,
              label: 'Complaint Type',
              required: true),
          AdminField(
              controller: _c.complaintSourceCtrl,
              label: 'Complaint Source',
              required: true),
          AdminField(
              controller: _c.complaintDateCtrl, label: 'Date (YYYY-MM-DD)'),
          AdminField(
              controller: _c.descriptionCtrl,
              label: 'Description',
              maxLines: 3),
          _section('Resolution'),
          AdminField(controller: _c.actionTakenCtrl, label: 'Action Taken'),
          AdminField(controller: _c.assignedCtrl, label: 'Assigned To'),
          const SizedBox(height: 8),
          Obx(() => _actionRow(
                isSaving: _c.isSaving.value,
                isEditing: _c.editingId.value != null,
                onSave: () async {
                  await _c.saveComplaint();
                  if (!_c.isSaving.value && sheetCtx.mounted)
                    Navigator.pop(sheetCtx);
                },
                onCancel: () {
                  _c.resetComplaintForm();
                  Navigator.pop(sheetCtx);
                },
              )),
        ]),
      ),
    );
  }

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

  Widget _empty(String msg, VoidCallback onRefresh, IconData icon) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
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

// ── Shared helpers (same pattern as visitor_book_view.dart) ─────────────────

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
                      style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4F46E5),
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
          backgroundColor: const Color(0xFF4F46E5),
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
