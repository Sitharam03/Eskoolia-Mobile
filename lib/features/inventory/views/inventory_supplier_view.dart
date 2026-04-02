import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_supplier_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class InventorySupplierView extends StatelessWidget {
  const InventorySupplierView({super.key});

  InventorySupplierController get _c =>
      Get.find<InventorySupplierController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventorySuppliers),
        Expanded(
          child: Obx(() {
            if (_c.isLoading.value) {
              return const SchoolLoader();
            }
            return RefreshIndicator(
              color: const Color(0xFF4F46E5),
              onRefresh: _c.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(children: [
                  _StatsRow(c: _c),
                  const SizedBox(height: 14),
                  _FormCard(c: _c),
                  Obx(() {
                    if (_c.errorMsg.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ErrorBanner(msg: _c.errorMsg.value),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 16),
                  _SearchBar(c: _c),
                  const SizedBox(height: 12),
                  _SupplierList(c: _c),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final InventorySupplierController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.suppliers.length;
      final byTerms = <String, int>{};
      for (final s in c.suppliers) {
        byTerms[s.paymentTerms] = (byTerms[s.paymentTerms] ?? 0) + 1;
      }
      final topTerm = byTerms.isEmpty
          ? '-'
          : byTerms.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
      return Row(children: [
        _StatTile(
            value: '$total',
            label: 'Total Suppliers',
            color: const Color(0xFF4F46E5),
            icon: Icons.business_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: '${c.suppliers.where((s) => s.email.isNotEmpty).length}',
            label: 'With Email',
            color: const Color(0xFF059669),
            icon: Icons.email_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: topTerm,
            label: 'Top Terms',
            color: const Color(0xFFEA580C),
            icon: Icons.receipt_long_rounded),
      ]);
    });
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatTile(
      {required this.value,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 16, color: color)),
                const SizedBox(height: 8),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827)),
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500)),
              ]),
        ),
      );
}

class _FormCard extends StatelessWidget {
  final InventorySupplierController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Obx(() => Column(children: [
            _FormHeader(
              icon: c.editingId.value != null
                  ? Icons.edit_rounded
                  : Icons.person_add_rounded,
              title: c.editingId.value != null
                  ? 'Edit Supplier'
                  : 'Add Supplier',
              subtitle: c.editingId.value != null
                  ? 'Update supplier details'
                  : 'Add a new supplier',
              onCancel:
                  c.editingId.value != null ? c.cancelEdit : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Supplier Name *'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.nameCtrl,
                        hint: 'e.g. ABC Trading Co.'),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sFieldLabel('Contact Person'),
                              const SizedBox(height: 6),
                              sTextField(
                                  controller: c.contactCtrl,
                                  hint: 'John Doe'),
                            ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sFieldLabel('Phone'),
                              const SizedBox(height: 6),
                              sTextField(
                                  controller: c.phoneCtrl,
                                  hint: '+1234567890',
                                  keyboardType:
                                      TextInputType.phone),
                            ]),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    sFieldLabel('Email'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.emailCtrl,
                        hint: 'supplier@example.com',
                        keyboardType:
                            TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    sFieldLabel('Address'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.addressCtrl,
                        hint: 'Street, City, Country',
                        maxLines: 2),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sFieldLabel('Tax ID'),
                              const SizedBox(height: 6),
                              sTextField(
                                  controller: c.taxIdCtrl,
                                  hint: 'TAX-12345'),
                            ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sFieldLabel('Payment Terms'),
                              const SizedBox(height: 6),
                              sDropdown<String>(
                                value: c.selectedPaymentTerms.value,
                                hint: 'Select',
                                items: InventorySupplierController
                                    .paymentTermsOptions
                                    .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    c.selectedPaymentTerms.value = v;
                                  }
                                },
                              ),
                            ]),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _SaveButton(
                        isSaving: c.isSaving.value,
                        isEditing: c.editingId.value != null,
                        onPressed: c.save),
                  ]),
            ),
          ])),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final InventorySupplierController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) => sSearchBar(
      hint: 'Search suppliers…',
      onChanged: (v) => c.searchQuery.value = v);
}

class _SupplierList extends StatelessWidget {
  final InventorySupplierController c;
  const _SupplierList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.filteredSuppliers;
      if (items.isEmpty) {
        return sEmptyState('No suppliers found', Icons.business_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Suppliers', count: items.length),
        const SizedBox(height: 10),
        ...items.map((s) => _SupplierCard(
              supplier: s,
              onEdit: () => c.startEdit(s),
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete supplier "${s.name}"?',
                      onConfirm: () => c.delete(s.id))),
            )),
      ]);
    });
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SupplierCard(
      {required this.supplier,
      required this.onEdit,
      required this.onDelete});

  String get _initials {
    final parts = supplier.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: const Color(0xFF4F46E5)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4F46E5),
                          const Color(0xFF4F46E5).withValues(alpha: 0.65)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(_initials,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(supplier.name,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827))),
                        const SizedBox(height: 3),
                        if (supplier.email.isNotEmpty)
                          _InfoRow(
                              icon: Icons.email_outlined,
                              text: supplier.email),
                        if (supplier.phone.isNotEmpty)
                          _InfoRow(
                              icon: Icons.phone_outlined,
                              text: supplier.phone),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(supplier.paymentTerms,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionBtn(
                          icon: Icons.edit_rounded,
                          color: const Color(0xFF0EA5E9),
                          onTap: onEdit),
                      const SizedBox(height: 6),
                      _ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          onTap: onDelete),
                    ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(children: [
          Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onCancel;
  const _FormHeader(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onCancel});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
            border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color:
                      const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 18, color: const Color(0xFF4F46E5))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827))),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
              ])),
          if (onCancel != null)
            GestureDetector(
                onTap: onCancel,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Color(0xFF6B7280)))),
        ]),
      );
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;
  const _SaveButton(
      {required this.isSaving,
      required this.isEditing,
      required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          icon: isSaving
              ? sSavingIndicator()
              : Icon(
                  isEditing
                      ? Icons.update_rounded
                      : Icons.save_rounded,
                  size: 18),
          label: Text(
              isSaving ? 'Saving…' : (isEditing ? 'Update' : 'Save'),
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0),
        ),
      );
}

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;
  const _ListHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        sectionHeader(title),
        Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20)),
            child: Text('$count records',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF4F46E5),
                    fontWeight: FontWeight.w600))),
      ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color)),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withValues(alpha: 0.08),
            border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFFDC2626)))),
        ]),
      );
}
