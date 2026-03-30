import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../models/admin_recipient_model.dart';
import '../widgets/admin_nav_tabs.dart';

class GenerateCertificateView extends StatefulWidget {
  const GenerateCertificateView({super.key});
  @override
  State<GenerateCertificateView> createState() => _GenerateCertificateViewState();
}

class _GenerateCertificateViewState extends State<GenerateCertificateView> {
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
    const AdminTabItem(label: 'Generate Certificate', route: AppRoutes.adminGenerateCertificate, isActive: true),
    const AdminTabItem(label: 'Generate ID Card', route: AppRoutes.adminGenerateIdCard),
  ];

  int? roleId;
  int? templateId;
  int? classId;
  int? sectionId;

  @override
  void initState() {
    super.initState();
    _c.loadCertificateTemplates();
    _c.loadGenerateSetup();
    _c.generateRecipients.clear();
    _c.selectedRecipientIds.clear();
  }

  bool get isStudent => _c.generateRoles.firstWhereOrNull((r) => r.id == roleId)?.name.toLowerCase().contains('student') ?? false;

  void _search() {
    if (roleId == null || templateId == null) {
      Get.snackbar('Error', 'Please select a Role and a Certificate template.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _c.searchCertificateRecipients(roleId!.toString(), classId?.toString(), sectionId?.toString());
  }

  String _replacePlaceholders(String body, AdminRecipient recipient) {
    final values = {
      'student_name': recipient.label,
      'name': recipient.label,
      'admission_no': recipient.admissionNo,
      'roll_no': recipient.rollNo,
      'class_name': recipient.className,
      'section_name': recipient.sectionName,
      'gender': recipient.gender,
      'date_of_birth': recipient.dateOfBirth,
      'today': DateTime.now().toString().split(' ').first,
    };

    String out = body;
    values.forEach((key, value) {
      out = out.replaceAll('{{$key}}', value).replaceAll('[$key]', value);
      // Handle space in braces if any
      out = out.replaceAll('{{ $key }}', value);
    });
    return out;
  }

  Future<void> _print() async {
    final t = _c.certificateTemplates.firstWhereOrNull((i) => i.id == templateId);
    if (t == null) return;
    if (_c.selectedRecipientIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one recipient.',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final targets = _c.generateRecipients.where((r) => _c.selectedRecipientIds.contains(r.id)).toList();
    
    pw.ImageProvider? bgImage;
    if (t.backgroundUrl.isNotEmpty) {
      try {
        bgImage = await networkImage(t.backgroundUrl);
      } catch (_) {}
    }

    final pdf = pw.Document();

    for (final recipient in targets) {
      final bodyText = _replacePlaceholders(t.body, recipient);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            t.backgroundWidth * PdfPageFormat.mm,
            t.backgroundHeight * PdfPageFormat.mm,
          ),
          margin: pw.EdgeInsets.fromLTRB(
            t.paddingLeft * PdfPageFormat.mm,
            t.paddingTop * PdfPageFormat.mm,
            t.paddingRight * PdfPageFormat.mm,
            t.paddingBottom * PdfPageFormat.mm,
          ),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                if (bgImage != null)
                  pw.Positioned.fill(
                    child: pw.Image(bgImage, fit: pw.BoxFit.cover),
                  ),
                pw.Center(
                  child: pw.Text(
                    bodyText,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Generate Certificate',
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
            final tOptions = _c.certificateTemplates.where((t) => roleId == null || t.applicableRoleId == null || t.applicableRoleId == roleId).toList();
            final sOptions = classId == null ? <dynamic>[] : _c.generateSections.where((s) => s.schoolClass == classId).toList();
            
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dropdown<int>('Role *', roleId, _c.generateRoles.map((r) => DropdownMenuItem<int>(value: r.id as int, child: Text(r.name as String))).toList(), (v) => setState(() { roleId = v; templateId = null; })),
                _dropdown<int>('Certificate *', templateId, tOptions.map((t) => DropdownMenuItem<int>(value: t.id as int, child: Text(t.title as String))).toList(), (v) => setState(() => templateId = v)),
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
              Text('Recipient List', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
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
              return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No recipients found.', style: GoogleFonts.inter(color: Colors.grey))));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _c.generateRecipients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = _c.generateRecipients[i];
                final selected = _c.selectedRecipientIds.contains(r.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: selected,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) {
                      if (v == true) _c.selectedRecipientIds.add(r.id);
                      else _c.selectedRecipientIds.remove(r.id);
                    },
                  ),
                  title: Text(r.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Adm: ${r.admissionNo.isEmpty ? '-' : r.admissionNo} | ${r.className.isEmpty ? '' : r.className}${r.sectionName.isEmpty ? '' : ' (${r.sectionName})'}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
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
