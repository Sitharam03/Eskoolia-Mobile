import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../models/admin_setup_model.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_form_sheet.dart';

class AdminSetupView extends StatefulWidget {
  const AdminSetupView({super.key});
  @override
  State<AdminSetupView> createState() => _AdminSetupViewState();
}

class _AdminSetupViewState extends State<AdminSetupView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static const _typeOptions = [
    ('1', 'Purpose'),
    ('2', 'Complaint Type'),
    ('3', 'Source'),
    ('4', 'Reference'),
  ];

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint),
    const AdminTabItem(label: 'Postal Receive', route: AppRoutes.adminPostalReceive),
    const AdminTabItem(label: 'Postal Dispatch', route: AppRoutes.adminPostalDispatch),
    const AdminTabItem(label: 'Phone Call Log', route: AppRoutes.adminPhoneCallLog),
    const AdminTabItem(label: 'Admin Setup', route: AppRoutes.adminSetup, isActive: true),
    const AdminTabItem(label: 'ID Card', route: AppRoutes.adminIdCard),
    const AdminTabItem(label: 'Certificate', route: AppRoutes.adminCertificate),
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard),
  ];

  @override
  void initState() {
    super.initState();
    _c.loadAdminSetups();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Setup',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        Expanded(child: _buildGroupedList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _c.resetSetupForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Setup'),
      ),
    );
  }

  Widget _buildGroupedList() {
    return Obx(() {
      if (_c.isLoading.value)
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)));
      return RefreshIndicator(
        color: const Color(0xFF6366F1),
        onRefresh: _c.loadAdminSetups,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: _typeOptions.map((opt) {
            final typeCode = opt.$1;
            final typeLabel = opt.$2;
            final items = _c.setupsForType(typeCode);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E4EF)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.settings_outlined,
                        color: Color(0xFF6366F1), size: 18),
                  ),
                  title: Text(typeLabel,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF111827))),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${items.length}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6366F1),
                            fontWeight: FontWeight.w600)),
                  ),
                  children: [
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Text('No entries. Tap + to add $typeLabel.',
                            style: GoogleFonts.inter(
                                color: const Color(0xFF9CA3AF), fontSize: 13)),
                      ),
                    ...items.map((s) => _setupRow(s)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _setupRow(AdminSetupItem s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4EF)),
      ),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.name,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF111827))),
          if (s.description.isNotEmpty)
            Text(s.description,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
        ])),
        _iconBtn(Icons.edit_outlined, const Color(0xFF0EA5E9), () {
          _c.startEditSetup(s);
          _showForm(context);
        }),
        const SizedBox(width: 6),
        _iconBtn(Icons.delete_outline, const Color(0xFFDC2626),
            () => _confirmDelete(s)),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );

  void _confirmDelete(AdminSetupItem s) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: Text('Delete "${s.name}" from ${s.typeLabel}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _c.deleteAdminSetup(s.id);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  void _showForm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _FormSheet(
        title:
            _c.editingId.value != null ? 'Edit Admin Setup' : 'Add Admin Setup',
        onClose: () {
          _c.resetSetupForm();
          Navigator.pop(sheetCtx);
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _section('Setup Type'),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _typeOptions.map((opt) {
                  final isSelected = _c.setupType.value == opt.$1;
                  return GestureDetector(
                    onTap: () => _c.setupType.value = opt.$1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE0E4EF)),
                      ),
                      child: Text(opt.$2,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280))),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 20),
          _section('Setup Details'),
          AdminField(
              controller: _c.setupNameCtrl, label: 'Name', required: true),
          AdminField(
              controller: _c.setupDescCtrl, label: 'Description', maxLines: 3),
          const SizedBox(height: 8),
          Obx(() => _actionRow(
                isSaving: _c.isSaving.value,
                isEditing: _c.editingId.value != null,
                onSave: () async {
                  await _c.saveAdminSetup();
                  if (!_c.isSaving.value && sheetCtx.mounted)
                    Navigator.pop(sheetCtx);
                },
                onCancel: () {
                  _c.resetSetupForm();
                  Navigator.pop(sheetCtx);
                },
              )),
        ]),
      ),
    );
  }
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
