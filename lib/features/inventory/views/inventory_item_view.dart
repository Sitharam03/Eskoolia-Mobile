import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_item_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class InventoryItemView extends StatelessWidget {
  const InventoryItemView({super.key});

  InventoryItemController get _c => Get.find<InventoryItemController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventoryItems),
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
                  _FilterBar(c: _c),
                  const SizedBox(height: 12),
                  _ItemList(c: _c),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final InventoryItemController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.items.length;
      final lowStock = c.lowStockCount;
      final totalQty = c.items.fold<double>(0, (s, i) => s + i.quantity);
      return Row(children: [
        _StatTile(
            value: '$total',
            label: 'Total Items',
            color: const Color(0xFF4F46E5),
            icon: Icons.inventory_2_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: '$lowStock',
            label: 'Low Stock',
            color: const Color(0xFFDC2626),
            icon: Icons.warning_amber_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: totalQty.toStringAsFixed(0),
            label: 'Total Qty',
            color: const Color(0xFF059669),
            icon: Icons.stacked_bar_chart_rounded),
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

// ── Form ──────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final InventoryItemController c;
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
                  : Icons.add_box_rounded,
              title: c.editingId.value != null ? 'Edit Item' : 'Add Item',
              subtitle: c.editingId.value != null
                  ? 'Update item details'
                  : 'Add a new inventory item',
              onCancel: c.editingId.value != null ? c.cancelEdit : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Item Code'),
                      const SizedBox(height: 6),
                      sTextField(controller: c.itemCodeCtrl, hint: 'e.g. ITM-001'),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Unit'),
                      const SizedBox(height: 6),
                      sDropdown<String>(
                        value: c.selectedUnit.value,
                        hint: 'Select unit',
                        items: InventoryItemController.unitOptions
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) c.selectedUnit.value = v;
                        },
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                sFieldLabel('Item Name *'),
                const SizedBox(height: 6),
                sTextField(controller: c.nameCtrl, hint: 'e.g. A4 Paper Ream'),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Category'),
                      const SizedBox(height: 6),
                      sDropdown<int>(
                        value: c.selectedCategoryId.value,
                        hint: 'Select category',
                        items: c.categories
                            .map((cat) => DropdownMenuItem(
                                value: cat.id, child: Text(cat.title)))
                            .toList(),
                        onChanged: (v) => c.selectedCategoryId.value = v,
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Supplier'),
                      const SizedBox(height: 6),
                      sDropdown<int>(
                        value: c.selectedSupplierId.value,
                        hint: 'Select supplier',
                        items: c.suppliers
                            .map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => c.selectedSupplierId.value = v,
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Quantity'),
                      const SizedBox(height: 6),
                      sTextField(
                          controller: c.quantityCtrl,
                          hint: '0',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Reorder Level'),
                      const SizedBox(height: 6),
                      sTextField(
                          controller: c.reorderLevelCtrl,
                          hint: '0',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Unit Cost'),
                      const SizedBox(height: 6),
                      sTextField(
                          controller: c.unitCostCtrl,
                          hint: '0.00',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sFieldLabel('Unit Price'),
                      const SizedBox(height: 6),
                      sTextField(
                          controller: c.unitPriceCtrl,
                          hint: '0.00',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true)),
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

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final InventoryItemController c;
  const _FilterBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      sSearchBar(
          hint: 'Search items…', onChanged: (v) => c.searchQuery.value = v),
      const SizedBox(height: 8),
      Obx(() => GestureDetector(
            onTap: () => c.showLowStockOnly.value = !c.showLowStockOnly.value,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.showLowStockOnly.value
                    ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                    : const Color(0xFFF9FAFB),
                border: Border.all(
                    color: c.showLowStockOnly.value
                        ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                        : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18,
                    color: c.showLowStockOnly.value
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Show Low Stock Only (${c.lowStockCount})',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: c.showLowStockOnly.value
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF374151)))),
                if (c.showLowStockOnly.value)
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFFDC2626)),
              ]),
            ),
          )),
    ]);
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final InventoryItemController c;
  const _ItemList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.filteredItems;
      if (items.isEmpty) {
        return sEmptyState('No items found', Icons.inventory_2_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Items', count: items.length),
        const SizedBox(height: 10),
        ...items.map((item) => _ItemCard(
              item: item,
              categoryName: c.categories
                  .firstWhereOrNull((cat) => cat.id == item.categoryId)
                  ?.title,
              onEdit: () => c.startEdit(item),
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete item "${item.name}"?',
                      onConfirm: () => c.delete(item.id))),
            )),
      ]);
    });
  }
}

class _ItemCard extends StatelessWidget {
  final InventoryItem item;
  final String? categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ItemCard(
      {required this.item,
      this.categoryName,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isLow = item.isLowStock;
    final accentColor =
        isLow ? const Color(0xFFDC2626) : const Color(0xFF4F46E5);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFDC2626).withValues(alpha: 0.02)
            : Colors.white,
        border: Border.all(
            color: isLow
                ? const Color(0xFFDC2626).withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB)),
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
          Container(width: 4, color: accentColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Icon(Icons.inventory_2_rounded,
                            size: 22, color: accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(item.name,
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827))),
                                ),
                                if (isLow)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          size: 11, color: Color(0xFFDC2626)),
                                      const SizedBox(width: 3),
                                      Text('Low Stock',
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFFDC2626),
                                              fontWeight: FontWeight.w700)),
                                    ]),
                                  ),
                              ]),
                              if (item.itemCode.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(item.itemCode,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500)),
                              ],
                              if (categoryName != null)
                                Text(categoryName!,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF4F46E5),
                                        fontWeight: FontWeight.w500)),
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MetricChip(
                                label: 'Qty',
                                value:
                                    '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                                color: isLow
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF059669)),
                            _Divider(),
                            _MetricChip(
                                label: 'Reorder',
                                value: item.reorderLevel.toStringAsFixed(0),
                                color: const Color(0xFFEA580C)),
                            _Divider(),
                            _MetricChip(
                                label: 'Cost',
                                value: item.unitCost.toStringAsFixed(2),
                                color: const Color(0xFF8B5CF6)),
                            _Divider(),
                            _MetricChip(
                                label: 'Price',
                                value: item.unitPrice.toStringAsFixed(2),
                                color: const Color(0xFF4F46E5)),
                          ]),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500)),
      ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: const Color(0xFFE5E7EB));
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
              child:
                  Icon(icon, size: 18, color: const Color(0xFF4F46E5))),
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
                ]),
          ),
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
                  isEditing ? Icons.update_rounded : Icons.save_rounded,
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
