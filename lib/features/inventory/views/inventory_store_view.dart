import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/inventory_store_controller.dart';
import '../models/inventory_models.dart';
import '_inventory_nav_tabs.dart';

class InventoryStoreView extends StatelessWidget {
  const InventoryStoreView({super.key});

  InventoryStoreController get _c => Get.find<InventoryStoreController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inventory',
      body: Column(children: [
        const InventoryNavTabs(activeRoute: AppRoutes.inventoryStores),
        Expanded(
          child: Obx(() {
            if (_c.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF4F46E5)));
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
                  _StoreList(c: _c),
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
  final InventoryStoreController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.stores.length;
      return Row(children: [
        _StatTile(
            value: '$total',
            label: 'Total Stores',
            color: const Color(0xFF4F46E5),
            icon: Icons.store_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: '${c.stores.where((s) => s.location.isNotEmpty).length}',
            label: 'With Location',
            color: const Color(0xFF059669),
            icon: Icons.location_on_rounded),
        const SizedBox(width: 8),
        _StatTile(
            value: '${c.stores.where((s) => s.description.isNotEmpty).length}',
            label: 'Described',
            color: const Color(0xFF8B5CF6),
            icon: Icons.description_rounded),
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
  Widget build(BuildContext context) {
    return Expanded(
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
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
}

class _FormCard extends StatelessWidget {
  final InventoryStoreController c;
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
                  : Icons.add_business_rounded,
              title: c.editingId.value != null
                  ? 'Edit Store'
                  : 'Add Store',
              subtitle: c.editingId.value != null
                  ? 'Update store details'
                  : 'Create a new item store',
              onCancel:
                  c.editingId.value != null ? c.cancelEdit : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Store Title *'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.titleCtrl,
                        hint: 'e.g. Main Warehouse'),
                    const SizedBox(height: 14),
                    sFieldLabel('Location'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.locationCtrl,
                        hint: 'e.g. Building A, Room 101'),
                    const SizedBox(height: 14),
                    sFieldLabel('Description'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.descCtrl,
                        hint: 'Optional description',
                        maxLines: 3),
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
  final InventoryStoreController c;
  const _SearchBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return sSearchBar(
        hint: 'Search stores…',
        onChanged: (v) => c.searchQuery.value = v);
  }
}

class _StoreList extends StatelessWidget {
  final InventoryStoreController c;
  const _StoreList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.filteredStores;
      if (items.isEmpty) {
        return sEmptyState('No stores found', Icons.store_mall_directory_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Stores', count: items.length),
        const SizedBox(height: 10),
        ...items.map((s) => _StoreCard(
              store: s,
              onEdit: () => c.startEdit(s),
              onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete store "${s.title}"?',
                      onConfirm: () => c.delete(s.id))),
            )),
      ]);
    });
  }
}

class _StoreCard extends StatelessWidget {
  final ItemStore store;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _StoreCard(
      {required this.store,
      required this.onEdit,
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
                      color:
                          const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.store_rounded,
                      size: 22, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.title,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827))),
                        if (store.location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.location_on_rounded,
                                size: 13, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(store.location,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ],
                        if (store.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(store.description,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
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
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF))),
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
                      size: 16, color: Color(0xFF6B7280))),
            ),
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
              isSaving
                  ? 'Saving…'
                  : (isEditing ? 'Update' : 'Save'),
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
                  fontWeight: FontWeight.w600)),
        ),
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
