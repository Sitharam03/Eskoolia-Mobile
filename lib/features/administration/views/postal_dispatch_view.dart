import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_record_card.dart';
import '../widgets/admin_form_sheet.dart';

class PostalDispatchView extends StatefulWidget {
  const PostalDispatchView({super.key});
  @override
  State<PostalDispatchView> createState() => _PostalDispatchViewState();
}

class _PostalDispatchViewState extends State<PostalDispatchView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint),
    const AdminTabItem(label: 'Postal Receive', route: AppRoutes.adminPostalReceive),
    const AdminTabItem(label: 'Postal Dispatch', route: AppRoutes.adminPostalDispatch, isActive: true),
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
    _c.loadPostalDispatch();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Postal Dispatch',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search postal dispatch...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _c.resetPostalForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Dispatch'),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value)
        return const SchoolLoader();
      final items = _c.filteredPostalDispatch;
      if (items.isEmpty)
        return _empty(
            'No postal dispatch records.\nTap + to add the first entry.',
            _c.loadPostalDispatch);
      return RefreshIndicator(
        color: const Color(0xFF6366F1),
        onRefresh: _c.loadPostalDispatch,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i];
            return AdminRecordCard(
              icon: Icons.outbox_rounded,
              iconColor: const Color(0xFF0EA5E9),
              title: 'To: ${p.toTitle}',
              subtitle:
                  'From: ${p.fromTitle}${p.date.isNotEmpty ? ' · ${p.date}' : ''}',
              onEdit: () {
                _c.startEditPostal(p);
                _showForm(context);
              },
              onDelete: () => _confirmDelete(
                  'Delete dispatch to "${p.toTitle}"?',
                  () => _c.deletePostalDispatch(p.id)),
              extraBadges: [
                _badge('Ref: ${p.referenceNo}', const Color(0xFF6B7280)),
                if (p.address.isNotEmpty)
                  _badge('Addr: ${p.address}', const Color(0xFF7C3AED)),
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
        title: _c.editingId.value != null
            ? 'Edit Postal Dispatch'
            : 'Add Postal Dispatch',
        onClose: () {
          _c.resetPostalForm();
          Navigator.pop(sheetCtx);
        },
        child: Column(children: [
          _section('Recipient Info'),
          AdminField(
              controller: _c.toTitleCtrl, label: 'To Title', required: true),
          AdminField(
              controller: _c.addressCtrl,
              label: 'Address',
              required: true,
              maxLines: 2),
          _section('Dispatch Details'),
          AdminField(
              controller: _c.fromTitleCtrl,
              label: 'From Title',
              required: true),
          AdminField(
              controller: _c.refNoCtrl, label: 'Reference No', required: true),
          AdminField(controller: _c.postalDateCtrl, label: 'Date (YYYY-MM-DD)'),
          AdminField(controller: _c.noteCtrl, label: 'Note', maxLines: 3),
          const SizedBox(height: 8),
          Obx(() => _actionRow(
                isSaving: _c.isSaving.value,
                isEditing: _c.editingId.value != null,
                onSave: () async {
                  await _c.savePostalDispatch();
                  if (!_c.isSaving.value && sheetCtx.mounted)
                    Navigator.pop(sheetCtx);
                },
                onCancel: () {
                  _c.resetPostalForm();
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

  Widget _empty(String msg, VoidCallback onRefresh) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.outbox_outlined, size: 64, color: Colors.grey.shade300),
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

// ── Shared helpers ──────────────────────────────────────────────────────────

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                  child: child)),
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

Widget _actionRow(
        {required bool isSaving,
        required bool isEditing,
        required VoidCallback onSave,
        required VoidCallback onCancel}) =>
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
        const SizedBox(width: 12),
      ],
      Expanded(
          child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEditing ? 'Update' : 'Save',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
    ]);
