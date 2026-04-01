import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../models/id_card_model.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_record_card.dart';
import '../widgets/admin_form_sheet.dart';

class IdCardView extends StatefulWidget {
  const IdCardView({super.key});
  @override
  State<IdCardView> createState() => _IdCardViewState();
}

class _IdCardViewState extends State<IdCardView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint),
    const AdminTabItem(label: 'Postal Receive', route: AppRoutes.adminPostalReceive),
    const AdminTabItem(label: 'Postal Dispatch', route: AppRoutes.adminPostalDispatch),
    const AdminTabItem(label: 'Phone Call Log', route: AppRoutes.adminPhoneCallLog),
    const AdminTabItem(label: 'Admin Setup', route: AppRoutes.adminSetup),
    const AdminTabItem(label: 'ID Card', route: AppRoutes.adminIdCard, isActive: true),
    const AdminTabItem(label: 'Certificate', route: AppRoutes.adminCertificate),
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard),
  ];

  final titleCtrl = TextEditingController();
  String layoutStyle = 'horizontal';

  @override
  void initState() {
    super.initState();
    _c.loadIdCardTemplates();
    _c.loadGenerateSetup(); // loads roles
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _c.editingId.value = null;
    titleCtrl.clear();
    layoutStyle = 'horizontal';
    _c.idCardRoleIds.clear();
    _c.idCardBackgroundPath.value = null;
    _c.idCardProfilePath.value = null;
    _c.idCardLogoPath.value = null;
    _c.idCardSignaturePath.value = null;
  }

  void _startEdit(IdCardTemplate t) {
    _c.editingId.value = t.id;
    titleCtrl.text = t.title;
    layoutStyle = t.pageLayoutStyle;
    _c.idCardRoleIds.assignAll(t.applicableRoleIds);
    _c.idCardBackgroundPath.value = null; // Don't download, just clear file path
    _c.idCardProfilePath.value = null;
    _c.idCardLogoPath.value = null;
    _c.idCardSignaturePath.value = null;
  }

  Future<void> _pickFile(RxnString rxPath) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.single.path != null) {
      rxPath.value = res.files.single.path!;
    }
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    final roleIds = _c.idCardRoleIds.toList();
    if (roleIds.isEmpty && _c.generateRoles.isNotEmpty) {
      // If no roles selected, default to all roles or empty
    }

    final Map<String, dynamic> data = {
      'title': titleCtrl.text.trim(),
      'page_layout_style': layoutStyle,
      'applicable_role_ids': jsonEncode(roleIds),
    };

    if (_c.idCardBackgroundPath.value != null) {
      data['background_upload'] = await dio.MultipartFile.fromFile(_c.idCardBackgroundPath.value!);
    }
    if (_c.idCardProfilePath.value != null) {
      data['profile_upload'] = await dio.MultipartFile.fromFile(_c.idCardProfilePath.value!);
    }
    if (_c.idCardLogoPath.value != null) {
      data['logo_upload'] = await dio.MultipartFile.fromFile(_c.idCardLogoPath.value!);
    }
    if (_c.idCardSignaturePath.value != null) {
      data['signature_upload'] = await dio.MultipartFile.fromFile(_c.idCardSignaturePath.value!);
    }

    final formData = dio.FormData.fromMap(data);
    await _c.saveIdCardTemplate(formData, id: _c.editingId.value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ID Card Templates',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search templates...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _resetForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Template'),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value && _c.idCardTemplates.isEmpty)
        return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
      final items = _c.idCardTemplates.where((i) => i.title.toLowerCase().contains(_c.searchQuery.value.trim().toLowerCase())).toList();
      if (items.isEmpty)
        return _empty('No templates found.', _c.loadIdCardTemplates);
      return RefreshIndicator(
        color: const Color(0xFF6366F1),
        onRefresh: _c.loadIdCardTemplates,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final t = items[i];
            return AdminRecordCard(
              icon: Icons.badge_outlined,
              iconColor: const Color(0xFF6366F1),
              title: t.title,
              subtitle: 'Layout: ${t.pageLayoutStyle.capitalizeFirst} | Roles: ${t.applicableRoleIds.length}',
              onEdit: () {
                _startEdit(t);
                _showForm(context);
              },
              onDelete: () => _confirmDelete('Delete template "${t.title}"?', () => _c.deleteIdCardTemplate(t.id)),
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
      builder: (sheetCtx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.92),
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
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
            child: Row(children: [
              Expanded(
                  child: Text(_c.editingId.value != null ? 'Edit ID Card' : 'Add ID Card',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827)))),
              IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)), onPressed: () => Navigator.pop(sheetCtx)),
            ]),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AdminField(controller: titleCtrl, label: 'Title', required: true),
                const SizedBox(height: 16),
                Text('Layout Style', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: layoutStyle,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'horizontal', child: Text('Horizontal')),
                    DropdownMenuItem(value: 'vertical', child: Text('Vertical')),
                  ],
                  onChanged: (v) => setState(() => layoutStyle = v!),
                ),
                const SizedBox(height: 16),
                Text('Applicable Roles', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _c.generateRoles.map((r) {
                    final selected = _c.idCardRoleIds.contains(r.id);
                    return FilterChip(
                      label: Text(r.name, style: GoogleFonts.inter(fontSize: 12)),
                      selected: selected,
                      selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      checkmarkColor: const Color(0xFF6366F1),
                      onSelected: (val) {
                        if (val) _c.idCardRoleIds.add(r.id);
                        else _c.idCardRoleIds.remove(r.id);
                      },
                    );
                  }).toList(),
                )),
                const SizedBox(height: 24),
                _filePickerRow('Background Image', _c.idCardBackgroundPath),
                _filePickerRow('Profile Placeholder', _c.idCardProfilePath),
                _filePickerRow('Logo Image', _c.idCardLogoPath),
                _filePickerRow('Signature Image', _c.idCardSignaturePath),
                const SizedBox(height: 24),
                Obx(() => _actionRow(
                  isSaving: _c.isSaving.value,
                  isEditing: _c.editingId.value != null,
                  onSave: () async {
                    await _save();
                    if (!_c.isSaving.value && sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  onCancel: () {
                    _resetForm();
                    Navigator.pop(sheetCtx);
                  },
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _filePickerRow(String label, RxnString rxPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: () => _pickFile(rxPath),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade800,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Obx(() => Text(
            rxPath.value?.split('/').last ?? 'No file selected',
            style: GoogleFonts.inter(fontSize: 12, color: rxPath.value != null ? const Color(0xFF6366F1) : Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ))),
          if (rxPath.value != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => rxPath.value = null,
            )
        ]),
      ]),
    );
  }

  void _confirmDelete(String msg, VoidCallback fn) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: Text(msg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  fn();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                child: const Text('Delete')),
          ],
        ),
      );

  Widget _empty(String msg, VoidCallback onRefresh) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.badge_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(msg, style: GoogleFonts.inter(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
        ]),
      );

  Widget _actionRow({
    required bool isSaving,
    required bool isEditing,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) => Row(children: [
        if (isEditing) ...[
          Expanded(
              child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEditing ? 'Update' : 'Save', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        )),
      ]);
}
