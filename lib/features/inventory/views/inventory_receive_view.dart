import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_receive_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';

class InventoryReceiveView extends StatelessWidget {
  const InventoryReceiveView({super.key});

  InventoryReceiveController get _c =>
      Get.find<InventoryReceiveController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventoryReceive),
        Expanded(
          child: Obx(() {
            if (_c.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
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
                  _ReceiveList(c: _c),
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
  final InventoryReceiveController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.receives.length;
      final paid = c.receives.where((r) => r.paymentStatus == 'P').length;
      final unpaid = c.receives.where((r) => r.paymentStatus == 'U').length;
      final totalValue =
          c.receives.fold<double>(0, (s, r) => s + r.total);
      return Column(children: [
        Row(children: [
          _StatTile(
              value: '$total',
              label: 'Total GRNs',
              color: const Color(0xFF4F46E5),
              icon: Icons.receipt_long_rounded),
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
              color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15))),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_rounded,
                size: 18, color: Color(0xFF4F46E5)),
            const SizedBox(width: 8),
            Text('Total Received Value:',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF374151))),
            const SizedBox(width: 8),
            Text(totalValue.toStringAsFixed(2),
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4F46E5))),
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

// ── Form ──────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final InventoryReceiveController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        _FormHeader(
            icon: Icons.add_shopping_cart_rounded,
            title: 'New Goods Receipt',
            subtitle: 'Record incoming inventory'),
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
                            sFieldLabel('Supplier'),
                            const SizedBox(height: 6),
                            sDropdown<int>(
                              value: c.selectedSupplierId.value,
                              hint: 'Select supplier',
                              items: c.suppliers
                                  .map((s) => DropdownMenuItem(
                                      value: s.id, child: Text(s.name)))
                                  .toList(),
                              onChanged: (v) =>
                                  c.selectedSupplierId.value = v,
                            ),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Receive Date *'),
                            const SizedBox(height: 6),
                            _DateField(
                                controller: c.receiveDateCtrl,
                                context: context),
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
                        border: Border.all(color: const Color(0xFFE5E7EB))),
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
                                  items: InventoryReceiveController
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
                      label: 'Save Receipt',
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
  final ReceiveLineItemForm form;
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
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  sFieldLabel('Unit Cost'),
                  const SizedBox(height: 4),
                  sTextField(
                      controller: form.costCtrl,
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

// ── List ──────────────────────────────────────────────────────────────────────

class _ReceiveList extends StatelessWidget {
  final InventoryReceiveController c;
  const _ReceiveList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.receives;
      if (items.isEmpty) {
        return sEmptyState(
            'No goods receipts yet', Icons.receipt_long_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Goods Receipts', count: items.length),
        const SizedBox(height: 10),
        ...items.map((r) => _ReceiveCard(
              receive: r,
              supplierName: c.suppliers
                  .firstWhereOrNull((s) => s.id == r.supplierId)
                  ?.name,
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete this goods receipt?',
                      onConfirm: () => c.delete(r.id))),
            )),
      ]);
    });
  }
}

class _ReceiveCard extends StatelessWidget {
  final ItemReceive receive;
  final String? supplierName;
  final VoidCallback onDelete;
  const _ReceiveCard(
      {required this.receive,
      this.supplierName,
      required this.onDelete});

  Color get _statusColor {
    switch (receive.paymentStatus) {
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
                                supplierName ?? 'No Supplier',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827)),
                              ),
                              const SizedBox(height: 3),
                              Text(receive.receiveDate,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280))),
                            ]),
                      ),
                      sBadge(receive.paymentLabel, _statusColor),
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
                                value: receive.total.toStringAsFixed(2),
                                color: const Color(0xFF4F46E5)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Discount',
                                value:
                                    receive.discount.toStringAsFixed(2),
                                color: const Color(0xFF059669)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Tax',
                                value: receive.tax.toStringAsFixed(2),
                                color: const Color(0xFFEA580C)),
                            Container(
                                width: 1,
                                height: 28,
                                color: const Color(0xFFE5E7EB)),
                            _ValChip(
                                label: 'Paid',
                                value: receive.paidAmount.toStringAsFixed(2),
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
              child:
                  Icon(icon, size: 18, color: const Color(0xFF4F46E5))),
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
