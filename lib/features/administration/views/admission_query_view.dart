import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/administration_controller.dart';
import '../models/admin_setup_model.dart';
import '../widgets/admin_nav_tabs.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_record_card.dart';
import '../widgets/admin_form_sheet.dart';

class AdmissionQueryView extends StatefulWidget {
  const AdmissionQueryView({super.key});
  @override
  State<AdmissionQueryView> createState() => _AdmissionQueryViewState();
}

class _AdmissionQueryViewState extends State<AdmissionQueryView> {
  AdministrationController get _c => Get.find<AdministrationController>();

  // static const _statusOptions = [
  //   ('new', 'New'),
  //   ('contacted', 'Contacted'),
  //   ('visited', 'Visited'),
  //   ('enrolled', 'Enrolled'),
  //   ('declined', 'Declined'),
  // ];

  static final _tabs = [
    const AdminTabItem(label: 'Admission Query', route: AppRoutes.adminAdmissionQuery, isActive: true),
    const AdminTabItem(label: 'Visitor Book', route: AppRoutes.adminVisitorBook),
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
    // Load both data sets — queries for list, setups for dropdowns
    _c.loadAdmissionQueries();
    if (_c.adminSetups.isEmpty) _c.loadAdminSetups();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admission Query',
      body: Column(children: [
        AdminNavTabs(tabs: _tabs),
        AdminSearchBar(
            hint: 'Search queries...',
            onChanged: (v) => _c.searchQuery.value = v),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _c.resetQueryForm();
          _showForm(context);
        },
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Query'),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      }
      final items = _c.filteredAdmissionQueries;
      if (items.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.help_outline_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No admission queries found.\nTap + to add the first query.',
                style: GoogleFonts.inter(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: _c.loadAdmissionQueries,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh')),
          ]),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadAdmissionQueries,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final a = items[i];
            return AdminRecordCard(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF7C3AED),
              title: a.fullName,
              subtitle: _cardSubtitle(a),
              onEdit: () {
                _c.startEditQuery(a);
                _showForm(context);
              },
              onDelete: () => _confirmDelete(
                'Delete query for "${a.fullName}"?',
                () => _c.deleteAdmissionQuery(a.id),
              ),
              extraBadges: [
                _statusBadge(a.status, a.statusLabel),
                _badge(
                    a.activeStatus == 1 ? 'Active' : 'Inactive',
                    a.activeStatus == 1
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626)),
                if (a.sourceName.isNotEmpty)
                  _badge('Src: ${a.sourceName}', const Color(0xFF0EA5E9)),
              ],
            );
          },
        ),
      );
    });
  }

  String _cardSubtitle(a) {
    final parts = <String>[];
    if ((a.phone as String).isNotEmpty) parts.add(a.phone as String);
    if ((a.className as String).isNotEmpty) parts.add('Class: ${a.className}');
    if ((a.queryDate as String).isNotEmpty) parts.add(a.queryDate as String);
    return parts.join(' · ');
  }

  // ── Badges ────────────────────────────────────────────────────────────────

  Widget _statusBadge(String status, String label) {
    final color = status == 'enrolled'
        ? const Color(0xFF059669)
        : status == 'declined'
            ? const Color(0xFFDC2626)
            : status == 'visited'
                ? const Color(0xFF0EA5E9)
                : status == 'contacted'
                    ? const Color(0xFFD97706)
                    : const Color(0xFF6B7280);
    return _badge(label, color);
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );

  // ── Delete confirm ────────────────────────────────────────────────────────

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
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  // ── Form ──────────────────────────────────────────────────────────────────

  void _showForm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.92,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(children: [
                  Expanded(
                    child: Obx(() => Text(
                          _c.editingId.value != null
                              ? 'Edit Admission Query'
                              : 'Add Admission Query',
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827)),
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF6B7280)),
                    onPressed: () {
                      _c.resetQueryForm();
                      Navigator.pop(sheetCtx);
                    },
                  ),
                ]),
              ),
              const Divider(height: 1),
              // Scrollable form body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Basic Info'),
                      AdminField(
                          controller: _c.queryFullNameCtrl,
                          label: 'Full Name',
                          required: true),
                      AdminField(
                          controller: _c.queryPhoneCtrl,
                          label: 'Phone',
                          required: true,
                          keyboardType: TextInputType.phone),
                      AdminField(
                          controller: _c.queryEmailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress),
                      AdminField(
                          controller: _c.queryClassCtrl,
                          label: 'Class Interested'),
                      AdminField(
                          controller: _c.queryDateCtrl,
                          label: 'Inquiry Date (YYYY-MM-DD)'),

                      _sectionLabel('Assignment'),
                      AdminField(
                          controller: _c.queryAssignedCtrl,
                          label: 'Assigned To'),

                      // Source dropdown (AdminSetup type "3")
                      _dropdownLabel('Source'),
                      Obx(() {
                        final sources = _c.setupsForType('3');
                        return _buildDropdown<AdminSetupItem?>(
                          value: sources.isEmpty
                              ? null
                              : sources
                                  .where(
                                      (s) => s.id == _c.selectedSourceId.value)
                                  .firstOrNull,
                          hint: 'Select source...',
                          items: [
                            const DropdownMenuItem<AdminSetupItem?>(
                                value: null, child: Text('-- None --')),
                            ...sources
                                .map((s) => DropdownMenuItem<AdminSetupItem?>(
                                      value: s,
                                      child: Text(s.name),
                                    )),
                          ],
                          onChanged: (v) => _c.selectedSourceId.value = v?.id,
                        );
                      }),

                      // Reference dropdown (AdminSetup type "4")
                      _dropdownLabel('Reference'),
                      Obx(() {
                        final refs = _c.setupsForType('4');
                        return _buildDropdown<AdminSetupItem?>(
                          value: refs.isEmpty
                              ? null
                              : refs
                                  .where((r) =>
                                      r.id == _c.selectedReferenceId.value)
                                  .firstOrNull,
                          hint: 'Select reference...',
                          items: [
                            const DropdownMenuItem<AdminSetupItem?>(
                                value: null, child: Text('-- None --')),
                            ...refs
                                .map((r) => DropdownMenuItem<AdminSetupItem?>(
                                      value: r,
                                      child: Text(r.name),
                                    )),
                          ],
                          onChanged: (v) =>
                              _c.selectedReferenceId.value = v?.id,
                        );
                      }),

                      _sectionLabel('Status'),

                      // Inquiry status (new/contacted/visited/enrolled/declined) — chip row
                      // Text('Inquiry Status',
                      //     style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                      // const SizedBox(height: 8),
                      // Obx(() => Wrap(
                      //   spacing: 8, runSpacing: 8,
                      //   children: _statusOptions.map((opt) {
                      //     final isSelected = _c.queryStatus.value == opt.$1;
                      //     return GestureDetector(
                      //       onTap: () => _c.queryStatus.value = opt.$1,
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      //         decoration: BoxDecoration(
                      //           color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                      //           borderRadius: BorderRadius.circular(20),
                      //         ),
                      //         child: Text(opt.$2,
                      //             style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                      //                 color: isSelected ? Colors.white : const Color(0xFF6B7280))),
                      //       ),
                      //     );
                      //   }).toList(),
                      // )),
                      // const SizedBox(height: 14),

                      // Active / Inactive dropdown
                      _dropdownLabel('Active Status'),
                      Obx(() => _buildDropdown<int>(
                            value: _c.activeStatusValue.value,
                            hint: 'Select...',
                            items: const [
                              DropdownMenuItem<int>(
                                  value: 1, child: Text('Active')),
                              DropdownMenuItem<int>(
                                  value: 0, child: Text('Inactive')),
                            ],
                            onChanged: (v) =>
                                _c.activeStatusValue.value = v ?? 1,
                          )),

                      _sectionLabel('Additional Info'),
                      AdminField(
                          controller: _c.queryAddressCtrl,
                          label: 'Address',
                          maxLines: 2),
                      AdminField(
                          controller: _c.queryDescCtrl,
                          label: 'Description',
                          maxLines: 2),
                      AdminField(
                          controller: _c.queryNoteCtrl,
                          label: 'Note',
                          maxLines: 2),

                      const SizedBox(height: 8),
                      // Save / Cancel buttons
                      Obx(() => Row(children: [
                            if (_c.editingId.value != null) ...[
                              Expanded(
                                  child: OutlinedButton(
                                onPressed: () {
                                  _c.resetQueryForm();
                                  Navigator.pop(sheetCtx);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Cancel',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600)),
                              )),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                                child: ElevatedButton(
                              onPressed: _c.isSaving.value
                                  ? null
                                  : () async {
                                      await _c.saveAdmissionQuery();
                                      if (!_c.isSaving.value &&
                                          sheetCtx.mounted)
                                        Navigator.pop(sheetCtx);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _c.isSaving.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Obx(() => Text(
                                        _c.editingId.value != null
                                            ? 'Update'
                                            : 'Save',
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600),
                                      )),
                            )),
                          ])),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4F46E5),
                letterSpacing: 0.5)),
      );

  Widget _dropdownLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
      );

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF), fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          style:
              GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
