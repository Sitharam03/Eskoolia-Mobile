import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_type_controller.dart';
import '../models/fees_type_model.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';

class FeesTypeView extends StatelessWidget {
  const FeesTypeView({super.key});

  FeesTypeController get _c => Get.find<FeesTypeController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fees Type',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesTypes),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value &&
                  _c.types.isEmpty &&
                  _c.academicYears.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 12),
                      _buildFilterBar(),
                      const SizedBox(height: 8),
                      _buildList(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Inline form card ─────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: fCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                _c.editingId.value != null
                    ? 'Edit Fees Type'
                    : 'Add Fees Type',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700),
              )),
          const SizedBox(height: 14),

          // Row 1: Year + Group
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Academic Year *'),
                    Obx(() => fDropdown<int?>(
                          hint: 'Select year',
                          value: _c.formYearId.value,
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('Select year')),
                            ..._c.academicYears.map((y) =>
                                DropdownMenuItem(
                                    value: y.id,
                                    child: Text(y.title))),
                          ],
                          onChanged: (v) =>
                              _c.formYearId.value = v,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Fees Group *'),
                    Obx(() => fDropdown<int?>(
                          hint: 'Select group',
                          value: _c.formGroupId.value,
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('Select group')),
                            ..._c.groups.map((g) =>
                                DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.name))),
                          ],
                          onChanged: (v) =>
                              _c.formGroupId.value = v,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Name + Amount
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Type Name *'),
                    fTextField(_c.nameCtrl, 'e.g. Tuition Fee'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Amount *'),
                    fTextField(
                      _c.amountCtrl,
                      '0.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      prefixText: '₹ ',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          fLabel('Description'),
          fTextField(_c.descCtrl, 'Optional description'),
          const SizedBox(height: 12),

          // Active toggle
          Obx(() => Row(
                children: [
                  Switch.adaptive(
                    value: _c.formIsActive.value,
                    activeColor: kFeesPrimary,
                    onChanged: (v) => _c.formIsActive.value = v,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _c.formIsActive.value ? 'Active' : 'Inactive',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _c.formIsActive.value
                            ? kFeesPrimary
                            : const Color(0xFF6B7280)),
                  ),
                ],
              )),
          const SizedBox(height: 14),

          // Buttons
          Row(
            children: [
              Expanded(
                child: Obx(() => fPrimaryBtn(
                      label: _c.editingId.value != null
                          ? 'Update'
                          : 'Save',
                      loading: _c.isLoading.value,
                      onPressed: _c.saveType,
                    )),
              ),
              Obx(() {
                if (_c.editingId.value == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: OutlinedButton(
                    onPressed: _c.resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280))),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: fCardDecoration(),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: fDropdown<int?>(
                  hint: 'All Years',
                  value: _c.filterYearId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Years')),
                    ..._c.academicYears.map((y) =>
                        DropdownMenuItem(
                            value: y.id, child: Text(y.title))),
                  ],
                  onChanged: (v) => _c.filterYearId.value = v,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: fDropdown<int?>(
                  hint: 'All Groups',
                  value: _c.filterGroupId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Groups')),
                    ..._c.groups.map((g) => DropdownMenuItem(
                        value: g.id, child: Text(g.name))),
                  ],
                  onChanged: (v) => _c.filterGroupId.value = v,
                ),
              ),
              const SizedBox(width: 10),
              fActionBtn(Icons.refresh, kFeesPrimary, _c.loadAll),
            ],
          )),
    );
  }

  // ── Fee type list ────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.filtered;
      if (list.isEmpty) {
        return fEmptyState(
            _c.types.isEmpty
                ? 'No fee types yet.\nFill the form above to add one.'
                : 'No types match the selected filters.',
            icon: Icons.receipt_long_outlined);
      }
      return Column(
        children: list
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TypeCard(
                    type: t,
                    groupName: _c.groupName(t.feesGroup),
                    yearName: _c.yearName(t.academicYear),
                    onEdit: () => _c.startEdit(t),
                    onDelete: () => fDeleteDialog(
                      context,
                      'Delete fee type "${t.name}"?',
                      () => _c.deleteType(t.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }
}

// ── Type card ──────────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final FeesType type;
  final String groupName;
  final String yearName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TypeCard({
    required this.type,
    required this.groupName,
    required this.yearName,
    required this.onEdit,
    required this.onDelete,
  });

  static const _accent = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: fCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹ ${fmtAmt(type.amount)}',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _accent),
                          ),
                        ),
                      ],
                    ),
                    if (type.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        type.description,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(Icons.folder_outlined, groupName,
                            const Color(0xFF7C3AED)),
                        _chip(Icons.calendar_today_outlined,
                            yearName, const Color(0xFF6366F1)),
                        fActiveBadge(type.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fActionBtn(
                            Icons.edit_outlined, kFeesPrimary, onEdit),
                        const SizedBox(width: 8),
                        fActionBtn(
                            Icons.delete_outline, kFeesRed, onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      );
}
