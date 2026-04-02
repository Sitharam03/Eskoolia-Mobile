import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_sell_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class InventorySellView extends StatelessWidget {
  const InventorySellView({super.key});

  InventorySellController get _c => Get.find<InventorySellController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventorySell),
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
                  _SellList(c: _c),
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
  final InventorySellController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.sells.length;
      final paid = c.sells.where((s) => s.paymentStatus == 'P').length;
      final unpaid = c.sells.where((s) => s.paymentStatus == 'U').length;
      final totalRevenue = c.sells.fold<double>(0, (s, sell) => s + sell.total);
      return Column(children: [
        Row(children: [
          _StatTile(
              value: '$total',
              label: 'Total Sales',
              color: const Color(0xFF4F46E5),
              icon: Icons.point_of_sale_rounded),
          const SizedBox(width: 8),
          _StatTile(
              value: '$paid',
              label: 'Paid',
              color: const Color(0xFF059669),
              icon: Icons.check_circle_rounded),
          const SizedBox(width: 8),
          _StatTile(
              value: '$unpaid',
              label: 'Unpaid',
              color: const Color(0xFFDC2626),
              icon: Icons.pending_rounded),
        ]),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color:
                      const Color(0xFF059669).withValues(alpha: 0.2))),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded,
                size: 18, color: Color(0xFF059669)),
            const SizedBox(width: 8),
            Text('Total Revenue:',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF374151))),
            const SizedBox(width: 8),
            Text(totalRevenue.toStringAsFixed(2),
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669))),
          ]),
        ),
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
  final InventorySellController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        _FormHeader(
            icon: Icons.point_of_sale_rounded,
            title: 'New Sale',
            subtitle: 'Record a new inventory sale'),
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
                            sFieldLabel('Sell Date *'),
                            const SizedBox(height: 6),
                            _DateField(
                                controller: c.sellDateCtrl,
                                context: context),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Sold To'),
                            const SizedBox(height: 6),
                            sTextField(
                                controller: c.soldToCtrl,
                                hint: 'Customer name'),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Line Items',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827))),
                        _AddLineBtn(onTap: c.addLineItem),
                      ]),
                  const SizedBox(height: 8),
                  ...List.generate(
                    c.lineItems.length,
                    (i) => _LineItemRow(
                      index: i,
                      form: c.lineItems[i],
                      items: c.items,
                      canRemove: c.lineItems.length > 1,
                      onRemove: () => c.removeLineItem(i),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB))),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sFieldLabel('Discount'),
                                const SizedBox(height: 6),
                                sTextField(
                                    controller: c.discountCtrl,
                                    hint: '0.00',
                                    keyboardType: const TextInputType
                                        .numberWithOptions(decimal: true)),
                              ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sFieldLabel('Tax'),
                                const SizedBox(height: 6),
                                sTextField(
                                    controller: c.taxCtrl,
                                    hint: '0.00',
                                    keyboardType: const TextInputType
                                        .numberWithOptions(decimal: true)),
                              ]),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sFieldLabel('Paid Amount'),
                                const SizedBox(height: 6),
                                sTextField(
                                    controller: c.paidAmountCtrl,
                                    hint: '0.00',
                                    keyboardType: const TextInputType
                                        .numberWithOptions(decimal: true)),
                              ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sFieldLabel('Payment Status'),
                                const SizedBox(height: 6),
                                sDropdown<String>(
                                  value: c.selectedPaymentStatus.value,
                                  hint: 'Select',
                                  items: InventorySellController
                                      .paymentStatusOptions
                                      .map((o) => DropdownMenuItem(
                                          value: o.value,
                                          child: Text(o.label)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      c.selectedPaymentStatus.value = v;
                                    }
                                  },
                                ),
                              ]),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _SaveButton(
                      isSaving: c.isSaving.value,
                      label: 'Save Sale',
                      onPressed: c.save),
                ],
              )),
        ),
      ]),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final int index;
  final SellLineItemForm form;
  final List<InventoryItem> items;
  final bool canRemove;
  final VoidCallback onRemove;
  const _LineItemRow(
      {required this.index,
      required this.form,
      required this.items,
      required this.canRemove,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Item ${index + 1}',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280))),
          if (canRemove)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFDC2626)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.remove_rounded,
                      size: 14, color: Color(0xFFDC2626))),
            ),
        ]),
        const SizedBox(height: 8),
        Obx(() => sDropdown<int>(
              value: form.selectedItemId.value,
              hint: 'Select item',
              items: items
                  .map((i) =>
                      DropdownMenuItem(value: i.id, child: Text(i.name)))
                  .toList(),
              onChanged: (v) => form.selectedItemId.value = v,
            )),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Quantity'),
                  const SizedBox(height: 4),
                  sTextField(
                      controller: form.qtyCtrl,
                      hint: '1',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true)),
                ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Unit Price'),
                  const SizedBox(height: 4),
                  sTextField(
                      controller: form.priceCtrl,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true)),
                ]),
          ),
        ]),
      ]),
    );
  }
}

class _AddLineBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddLineBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded,
                size: 16, color: Color(0xFF4F46E5)),
            const SizedBox(width: 4),
            Text('Add Item',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5))),
          ]),
        ),
      );
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final BuildContext context;
  const _DateField({required this.controller, required this.context});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4F46E5))),
              child: child!,
            ),
          );
          if (picked != null) {
            controller.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        child: AbsorbPointer(
          child: sTextField(
              controller: controller,
              hint: 'YYYY-MM-DD',
              suffixIcon: const Icon(Icons.calendar_today_rounded,
                  size: 18, color: Color(0xFF9CA3AF))),
        ),
      );
}

class _SellList extends StatelessWidget {
  final InventorySellController c;
  const _SellList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sells = c.sells;
      if (sells.isEmpty) {
        return sEmptyState('No sales yet', Icons.point_of_sale_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Sales', count: sells.length),
        const SizedBox(height: 10),
        ...sells.map((sell) => _SellCard(
              sell: sell,
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete this sale record?',
                      onConfirm: () => c.delete(sell.id))),
            )),
      ]);
    });
  }
}

class _SellCard extends StatelessWidget {
  final ItemSell sell;
  final VoidCallback onDelete;
  const _SellCard({required this.sell, required this.onDelete});

  Color get _statusColor {
    switch (sell.paymentStatus) {
      case 'P':
        return const Color(0xFF059669);
      case 'PP':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFFDC2626);
    }
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
          Container(width: 4, color: _statusColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sell.soldTo.isNotEmpty
                                    ? sell.soldTo
                                    : 'Walk-in Customer',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827)),
                              ),
                              const SizedBox(height: 3),
                              Text(sell.sellDate,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280))),
                            ]),
                      ),
                      sBadge(sell.paymentLabel, _statusColor),
                      const SizedBox(width: 8),
                      _ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          onTap: onDelete),
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
                            _ValChip(
                                label: 'Total',
                                value: sell.total.toStringAsFixed(2),
                                color: const Color(0xFF4F46E5)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Discount',
                                value: sell.discount.toStringAsFixed(2),
                                color: const Color(0xFF059669)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Tax',
                                value: sell.tax.toStringAsFixed(2),
                                color: const Color(0xFFEA580C)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Paid',
                                value: sell.paidAmount.toStringAsFixed(2),
                                color: const Color(0xFF059669)),
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

class _ValChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ValChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500)),
      ]);
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
