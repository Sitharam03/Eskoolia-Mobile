import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../models/certificate_model.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_record_card.dart';
import '../widgets/admin_form_sheet.dart';

class CertificateView extends StatefulWidget {
  const CertificateView({super.key});
  @override
  State<CertificateView> createState() => _CertificateViewState();
}

class _CertificateViewState extends State<CertificateView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
    const AdminTabItem(label: 'Complaint', route: AppRoutes.adminComplaint),
    const AdminTabItem(label: 'Postal Receive', route: AppRoutes.adminPostalReceive),
    const AdminTabItem(label: 'Postal Dispatch', route: AppRoutes.adminPostalDispatch),
    const AdminTabItem(label: 'Phone Call Log', route: AppRoutes.adminPhoneCallLog),
    const AdminTabItem(label: 'Admin Setup', route: AppRoutes.adminSetup),
    const AdminTabItem(label: 'ID Card', route: AppRoutes.adminIdCard),
    const AdminTabItem(label: 'Certificate', route: AppRoutes.adminCertificate, isActive: true),
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard),
  ];

  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final heightCtrl = TextEditingController(text: '144');
  final widthCtrl = TextEditingController(text: '165');
  final ptCtrl = TextEditingController(text: '5');
  final prCtrl = TextEditingController(text: '5');
  final pbCtrl = TextEditingController(text: '5');
  final plCtrl = TextEditingController(text: '5');
  
  String certType = 'School';
  int? roleId;

  @override
  void initState() {
    super.initState();
    _c.loadCertificateTemplates();
    _c.loadGenerateSetup();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    heightCtrl.dispose();
    widthCtrl.dispose();
    ptCtrl.dispose();
    prCtrl.dispose();
    pbCtrl.dispose();
    plCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _c.editingId.value = null;
    titleCtrl.clear();
    bodyCtrl.clear();
    heightCtrl.text = '144';
    widthCtrl.text = '165';
    ptCtrl.text = '5';
    prCtrl.text = '5';
    pbCtrl.text = '5';
    plCtrl.text = '5';
    certType = 'School';
    roleId = null;
    _c.certBackgroundPath.value = null;
  }

  void _startEdit(CertificateTemplate t) {
    _c.editingId.value = t.id;
    titleCtrl.text = t.title;
    bodyCtrl.text = t.body;
    heightCtrl.text = t.backgroundHeight.toString();
    widthCtrl.text = t.backgroundWidth.toString();
    ptCtrl.text = t.paddingTop.toString();
    prCtrl.text = t.paddingRight.toString();
    pbCtrl.text = t.paddingBottom.toString();
    plCtrl.text = t.paddingLeft.toString();
    certType = t.type.isEmpty ? 'School' : t.type;
    roleId = t.applicableRoleId;
    _c.certBackgroundPath.value = null;
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.single.path != null) {
      _c.certBackgroundPath.value = res.files.single.path!;
    }
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title and Body are required.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final Map<String, dynamic> data = {
      'title': titleCtrl.text.trim(),
      'type': certType,
      'body': bodyCtrl.text.trim(),
      'background_height': heightCtrl.text.trim(),
      'background_width': widthCtrl.text.trim(),
      'padding_top': ptCtrl.text.trim(),
      'padding_right': prCtrl.text.trim(),
      'padding_bottom': pbCtrl.text.trim(),
      'pading_left': plCtrl.text.trim(), // backend typo map
      if (roleId != null) 'applicable_role_id': roleId.toString(),
    };

    if (_c.certBackgroundPath.value != null) {
      data['background_upload'] = await dio.MultipartFile.fromFile(_c.certBackgroundPath.value!);
    }

    final formData = dio.FormData.fromMap(data);
    await _c.saveCertificateTemplate(formData, id: _c.editingId.value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Certificate Templates',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search certificates...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _resetForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Template'),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value && _c.certificateTemplates.isEmpty)
        return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      final items = _c.certificateTemplates.where((i) => i.title.toLowerCase().contains(_c.searchQuery.value.trim().toLowerCase())).toList();
      if (items.isEmpty)
        return _empty('No templates found.', _c.loadCertificateTemplates);
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadCertificateTemplates,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final t = items[i];
            final roleName = _c.generateRoles.firstWhereOrNull((r) => r.id == t.applicableRoleId)?.name ?? 'All Roles';
            return AdminRecordCard(
              icon: Icons.workspace_premium_outlined,
              iconColor: const Color(0xFF4F46E5),
              title: t.title,
              subtitle: 'Type: ${t.type} | Role: $roleName',
              onEdit: () {
                _startEdit(t);
                _showForm(context);
              },
              onDelete: () => _confirmDelete('Delete template "${t.title}"?', () => _c.deleteCertificateTemplate(t.id)),
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
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setState) => Container(
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
                    child: Text(_c.editingId.value != null ? 'Edit Certificate' : 'Add Certificate',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827)))),
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
                  Text('Type', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: certType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'School', child: Text('School')),
                      DropdownMenuItem(value: 'Lms', child: Text('Lms')),
                    ],
                    onChanged: (v) => setState(() => certType = v!),
                  ),

                  const SizedBox(height: 16),
                  Text('Applicable Role', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<int?>(
                    value: roleId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('All Roles')),
                      ..._c.generateRoles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))),
                    ],
                    onChanged: (v) => setState(() => roleId = v),
                  )),

                  const SizedBox(height: 16),
                  Text('Body (Use {{ student_name }} etc)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Dimensions (mm)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: AdminField(controller: widthCtrl, label: 'Width (165)', keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: AdminField(controller: heightCtrl, label: 'Height (144)', keyboardType: TextInputType.number)),
                  ]),

                  const SizedBox(height: 16),
                  Text('Padding (mm)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: AdminField(controller: ptCtrl, label: 'Top', keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: AdminField(controller: prCtrl, label: 'Right', keyboardType: TextInputType.number)),
                  ]),
                  Row(children: [
                    Expanded(child: AdminField(controller: pbCtrl, label: 'Bottom', keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: AdminField(controller: plCtrl, label: 'Left', keyboardType: TextInputType.number)),
                  ]),

                  const SizedBox(height: 24),
                  _filePickerRow('Background Image', _c.certBackgroundPath),
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
            onPressed: () => _pickFile(),
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
            style: GoogleFonts.inter(fontSize: 12, color: rxPath.value != null ? const Color(0xFF4F46E5) : Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ))),
          Obx(() => rxPath.value != null
            ? IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: () => rxPath.value = null)
            : const SizedBox.shrink())
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
          Icon(Icons.workspace_premium_outlined, size: 64, color: Colors.grey.shade300),
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
            backgroundColor: const Color(0xFF4F46E5),
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
