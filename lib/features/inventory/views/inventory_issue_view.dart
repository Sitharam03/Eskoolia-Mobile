import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_issue_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class InventoryIssueView extends StatelessWidget {
  const InventoryIssueView({super.key});

  InventoryIssueController get _c => Get.find<InventoryIssueController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventoryIssue),
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
                  _IssueList(c: _c),
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
  final InventoryIssueController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.issues.length;
      final totalQty = c.issues.fold<double>(0, (s, i) => s + i.quantity);
      final uniqueItems =
          c.issues.map((i) => i.itemId).toSet().length;
      return Row(children: [
        _StatTile(
            value: '$total',
            label: 'Total Issues',
            color: const Color(0xFF4F46E5),
            icon: Icons.outbox_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: totalQty.toStringAsFixed(0),
            label: 'Total Qty',
            color: const Color(0xFFEA580C),
            icon: Icons.numbers_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: '$uniqueItems',
            label: 'Unique Items',
            color: const Color(0xFF8B5CF6),
            icon: Icons.category_outlined),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827))),
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
  final InventoryIssueController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        _FormHeader(
            icon: Icons.outbox_rounded,
            title: 'New Item Issue',
            subtitle: 'Issue items from inventory'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Item *'),
                            const SizedBox(height: 6),
                            sDropdown<int>(
                              value: c.selectedItemId.value,
                              hint: 'Select item',
                              items: c.items
                                  .map((i) => DropdownMenuItem(
                                      value: i.id, child: Text(i.name)))
                                  .toList(),
                              onChanged: (v) => c.selectedItemId.value = v,
                            ),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Store'),
                            const SizedBox(height: 6),
                            sDropdown<int>(
                              value: c.selectedStoreId.value,
                              hint: 'Select store',
                              items: c.stores
                                  .map((s) => DropdownMenuItem(
                                      value: s.id, child: Text(s.title)))
                                  .toList(),
                              onChanged: (v) => c.selectedStoreId.value = v,
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Quantity *'),
                            const SizedBox(height: 6),
                            sTextField(
                                controller: c.quantityCtrl,
                                hint: '1',
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true)),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Subject *'),
                            const SizedBox(height: 6),
                            sTextField(
                                controller: c.subjectCtrl,
                                hint: 'e.g. Class usage'),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  sFieldLabel('Notes'),
                  const SizedBox(height: 6),
                  sTextField(
                      controller: c.notesCtrl,
                      hint: 'Optional notes',
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _SaveButton(
                      isSaving: c.isSaving.value,
                      label: 'Issue Item',
                      onPressed: c.save),
                ],
              )),
        ),
      ]),
    );
  }
}

class _IssueList extends StatelessWidget {
  final InventoryIssueController c;
  const _IssueList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final issues = c.issues;
      if (issues.isEmpty) {
        return sEmptyState('No item issues yet', Icons.outbox_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Item Issues', count: issues.length),
        const SizedBox(height: 10),
        ...issues.map((issue) => _IssueCard(
              issue: issue,
              itemName: c.items
                  .firstWhereOrNull((i) => i.id == issue.itemId)
                  ?.name,
              storeName: c.stores
                  .firstWhereOrNull((s) => s.id == issue.storeId)
                  ?.title,
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete this item issue?',
                      onConfirm: () => c.delete(issue.id))),
            )),
      ]);
    });
  }
}

class _IssueCard extends StatelessWidget {
  final ItemIssue issue;
  final String? itemName;
  final String? storeName;
  final VoidCallback onDelete;
  const _IssueCard(
      {required this.issue,
      this.itemName,
      this.storeName,
      required this.onDelete});

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
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.outbox_rounded,
                      size: 22, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemName ?? 'Unknown Item',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827))),
                        const SizedBox(height: 3),
                        Text(issue.subject,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280))),
                        const SizedBox(height: 4),
                        Row(children: [
                          sBadge(
                              'Qty: ${issue.quantity.toStringAsFixed(0)}',
                              const Color(0xFF4F46E5)),
                          if (storeName != null) ...[
                            const SizedBox(width: 6),
                            sBadge(storeName!,
                                const Color(0xFF8B5CF6)),
                          ],
                        ]),
                        if (issue.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(issue.notes,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF9CA3AF),
                                  fontStyle: FontStyle.italic),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ]),
                ),
                _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFDC2626),
                    onTap: onDelete),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FormHeader(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
            border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: const Color(0xFF4F46E5))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF9CA3AF))),
          ]),
        ]),
      );
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final String label;
  final VoidCallback onPressed;
  const _SaveButton(
      {required this.isSaving,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          icon: isSaving
              ? sSavingIndicator()
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(isSaving ? 'Saving…' : label,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
