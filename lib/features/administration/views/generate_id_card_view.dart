import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../widgets/admin_nav_tabs.dart';

class GenerateIdCardView extends StatefulWidget {
  const GenerateIdCardView({super.key});
  @override
  State<GenerateIdCardView> createState() => _GenerateIdCardViewState();
}

class _GenerateIdCardViewState extends State<GenerateIdCardView> {
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
    const AdminTabItem(label: 'Certificate', route: AppRoutes.adminCertificate),
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard, isActive: true),
  ];

  int? roleId;
  int? templateId;
  int? classId;
  int? sectionId;
  final gapCtrl = TextEditingController(text: '12');

  @override
  void initState() {
    super.initState();
    _c.loadIdCardTemplates();
    _c.loadGenerateSetup();
    _c.generateRecipients.clear();
    _c.selectedRecipientIds.clear();
  }

  bool get isStudent => _c.generateRoles.firstWhereOrNull((r) => r.id == roleId)?.name.toLowerCase().contains('student') ?? false;

  void _search() {
    if (roleId == null || templateId == null) {
      Get.snackbar('Error', 'Please select a Role and an ID Card template.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _c.searchIdCardStudents(isStudent ? classId?.toString() : null, isStudent ? sectionId?.toString() : null);
  }

  Future<void> _print() async {
    final t = _c.idCardTemplates.firstWhereOrNull((i) => i.id == templateId);
    if (t == null) return;
    if (_c.selectedRecipientIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one student.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final targets = _c.generateRecipients.where((r) => _c.selectedRecipientIds.contains(r.id)).toList();
    final widthMm = t.plWidth ?? (t.pageLayoutStyle == 'horizontal' ? 85.0 : 55.0);
    final heightMm = t.plHeight ?? (t.pageLayoutStyle == 'horizontal' ? 54.0 : 85.0);
    final gapPx = double.tryParse(gapCtrl.text.trim()) ?? 12.0;

    // We use flutter printing to load images if needed, but since it's a URL we can fetch them via network provider
    pw.ImageProvider? bgImage;
    if (t.backgroundUrl.isNotEmpty) {
      try {
        bgImage = await networkImage(t.backgroundUrl);
      } catch (_) {}
    }

    pw.ImageProvider? logoImage;
    if (t.logoUrl.isNotEmpty) {
      try {
        logoImage = await networkImage(t.logoUrl);
      } catch (_) {}
    }

    pw.ImageProvider? sigImage;
    if (t.signatureUrl.isNotEmpty) {
      try {
        sigImage = await networkImage(t.signatureUrl);
      } catch (_) {}
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(14),
        build: (context) {
          return [
            pw.Wrap(
              spacing: gapPx,
              runSpacing: gapPx,
              children: targets.map((student) {
                final initials = student.label.split(' ').take(2).map((x) => x.isNotEmpty ? x[0].toUpperCase() : '').join();
                
                return pw.Container(
                  width: widthMm * PdfPageFormat.mm,
                  height: heightMm * PdfPageFormat.mm,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                    image: bgImage != null ? pw.DecorationImage(image: bgImage, fit: pw.BoxFit.cover) : null,
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Stack(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (logoImage != null) pw.Image(logoImage, width: 22 * PdfPageFormat.mm, height: 10 * PdfPageFormat.mm, fit: pw.BoxFit.contain),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            width: 18 * PdfPageFormat.mm,
                            height: 18 * PdfPageFormat.mm,
                            decoration: pw.BoxDecoration(color: PdfColors.grey300, shape: pw.BoxShape.circle),
                            alignment: pw.Alignment.center,
                            child: pw.Text(initials, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(student.label, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('Admission: ${student.admissionNo.isEmpty ? '-' : student.admissionNo}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Class: ${student.className.isEmpty ? '-' : student.className} (${student.sectionName.isEmpty ? '-' : student.sectionName})', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Roll: ${student.rollNo.isEmpty ? '-' : student.rollNo}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Gender: ${student.gender.isEmpty ? '-' : student.gender}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('DOB: ${student.dateOfBirth.isEmpty ? '-' : student.dateOfBirth}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      if (sigImage != null)
                        pw.Positioned(
                          right: 0,
                          bottom: 0,
                          child: pw.Image(sigImage, width: 25 * PdfPageFormat.mm, height: 10 * PdfPageFormat.mm, fit: pw.BoxFit.contain),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Generate ID Card',
      body: Column(
        children: [
          AdminNavTabs(tabs: _tabs),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildRecipientsTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Select Criteria', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Obx(() {
            final tOptions = _c.idCardTemplates.where((t) => roleId == null || t.applicableRoleIds.isEmpty || t.applicableRoleIds.contains(roleId)).toList();
            final sOptions = classId == null ? <dynamic>[] : _c.generateSections.where((s) => s.schoolClass == classId).toList();
            
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dropdown<int>('Role *', roleId, _c.generateRoles.map((r) => DropdownMenuItem<int>(value: r.id as int, child: Text(r.name as String))).toList(), (v) => setState(() { roleId = v; templateId = null; })),
                _dropdown<int>('Template *', templateId, tOptions.map((t) => DropdownMenuItem<int>(value: t.id as int, child: Text(t.title as String))).toList(), (v) => setState(() => templateId = v)),
                if (isStudent) _dropdown<int>('Class', classId, _c.generateClasses.map((c) => DropdownMenuItem<int>(value: c.id as int, child: Text(c.name as String))).toList(), (v) => setState(() { classId = v; sectionId = null; })),
                if (isStudent) _dropdown<int>('Section', sectionId, sOptions.map((s) => DropdownMenuItem<int>(value: s.id as int, child: Text(s.name as String))).toList(), (v) => setState(() => sectionId = v)),
              ],
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _search, style: _btnStyle(const Color(0xFF4F46E5)), child: Obx(() => Text(_c.isLoading.value ? 'Loading...' : 'Search')))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _print, style: _btnStyle(const Color(0xFF0F766E)), child: const Text('Print Selected'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student List', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              Obx(() {
                final allSelected = _c.generateRecipients.isNotEmpty && _c.selectedRecipientIds.length == _c.generateRecipients.length;
                return Row(
                  children: [
                    Text('Select All', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                    Checkbox(
                      value: allSelected,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (v) {
                        if (v == true) {
                          _c.selectedRecipientIds.assignAll(_c.generateRecipients.map((e) => e.id));
                        } else {
                          _c.selectedRecipientIds.clear();
                        }
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
          const Divider(),
          Obx(() {
            if (_c.isLoading.value && _c.generateRecipients.isEmpty) {
              return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            }
            if (_c.generateRecipients.isEmpty) {
              return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No students found.', style: GoogleFonts.inter(color: Colors.grey))));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _c.generateRecipients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = _c.generateRecipients[i];
                final selected = _c.selectedRecipientIds.contains(s.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: selected,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) {
                      if (v == true) _c.selectedRecipientIds.add(s.id);
                      else _c.selectedRecipientIds.remove(s.id);
                    },
                  ),
                  title: Text(s.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Adm: ${s.admissionNo.isEmpty ? '-' : s.admissionNo} | ${s.className} (${s.sectionName})', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _dropdown<T>(String hint, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  ButtonStyle _btnStyle(Color c) => ElevatedButton.styleFrom(
        backgroundColor: c,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}
