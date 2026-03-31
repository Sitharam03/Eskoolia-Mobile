import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/transport_assign_controller.dart';
import '../models/transport_models.dart';
import '_transport_nav_tabs.dart';

class TransportAssignView extends StatelessWidget {
  const TransportAssignView({super.key});

  TransportAssignController get _c => Get.find<TransportAssignController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transport',
      body: Column(children: [
        const TransportNavTabs(activeRoute: AppRoutes.transportAssignVehicles),
        Expanded(
          child: Obx(() {
            if (_c.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
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
                  _AssignList(c: _c),
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
  final TransportAssignController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.assignments.length;
      final active = c.assignments.where((a) => a.activeStatus).length;
      final uniqueRoutes = c.assignments.map((a) => a.routeId).toSet().length;
      return Row(children: [
        _StatTile(value: '$total', label: 'Assignments', color: const Color(0xFF4F46E5), icon: Icons.link_rounded),
        const SizedBox(width: 8),
        _StatTile(value: '$active', label: 'Active', color: const Color(0xFF059669), icon: Icons.check_circle_outline_rounded),
        const SizedBox(width: 8),
        _StatTile(value: '$uniqueRoutes', label: 'Routes Used', color: const Color(0xFF8B5CF6), icon: Icons.route_rounded),
      ]);
    });
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatTile({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center, child: Icon(icon, size: 16, color: color)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final TransportAssignController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Obx(() => Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
                border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                  alignment: Alignment.center,
                  child: Icon(c.editingId.value != null ? Icons.edit_rounded : Icons.link_rounded, size: 18, color: const Color(0xFF4F46E5))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.editingId.value != null ? 'Edit Assignment' : 'Assign Vehicle to Route',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                  Text(c.editingId.value != null ? 'Update the assignment' : 'Link a vehicle with a transport route',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                ])),
                if (c.editingId.value != null)
                  GestureDetector(onTap: c.cancelEdit,
                    child: Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sFieldLabel('Vehicle *'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: c.selectedVehicleId.value,
                  hint: 'Select Vehicle',
                  items: c.vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.vehicleNo, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => c.selectedVehicleId.value = v,
                ),
                const SizedBox(height: 14),
                sFieldLabel('Route *'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: c.selectedRouteId.value,
                  hint: 'Select Route',
                  items: c.routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.title, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => c.selectedRouteId.value = v,
                ),
                const SizedBox(height: 14),
                _ActiveToggle(value: c.isActive.value, onChanged: (v) => c.isActive.value = v),
                const SizedBox(height: 16),
                _SaveButton(isSaving: c.isSaving.value, isEditing: c.editingId.value != null, onPressed: c.save),
              ]),
            ),
          ])),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _AssignList extends StatelessWidget {
  final TransportAssignController c;
  const _AssignList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = c.vehicles.length;
      final __ = c.routes.length;
      final items = c.assignments.toList();
      if (items.isEmpty) return sEmptyState('No assignments yet', Icons.link_off_rounded);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Assignments', count: items.length),
        const SizedBox(height: 10),
        ...items.map((a) => _AssignCard(
          assign: a,
          onEdit: () => c.startEdit(a),
          onDelete: () => showDialog(context: context, builder: (_) => sDeleteDialog(
            context: context,
            message: 'Remove assignment of "${a.vehicleNo}" from "${a.routeTitle}"?',
            onConfirm: () => c.delete(a.id))),
        )),
      ]);
    });
  }
}

class _AssignCard extends StatelessWidget {
  final AssignVehicle assign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AssignCard({required this.assign, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: assign.activeStatus ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Vehicle icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.directions_bus_rounded, size: 22, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 10),
                // Arrow
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                // Route icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.route_rounded, size: 22, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(assign.vehicleNo.isNotEmpty ? assign.vehicleNo : 'Vehicle #${assign.vehicleId}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text(assign.routeTitle.isNotEmpty ? assign.routeTitle : 'Route #${assign.routeId}',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  sBadge(assign.activeStatus ? 'Active' : 'Inactive',
                      assign.activeStatus ? const Color(0xFF059669) : const Color(0xFF6B7280)),
                ])),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _ActionBtn(icon: Icons.edit_rounded, color: const Color(0xFF0EA5E9), onTap: onEdit),
                  const SizedBox(height: 6),
                  _ActionBtn(icon: Icons.delete_outline_rounded, color: const Color(0xFFDC2626), onTap: onDelete),
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

class _ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ActiveToggle({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Icon(value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, size: 22, color: value ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
      const SizedBox(width: 10),
      Expanded(child: Text('Active', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151), fontWeight: FontWeight.w500))),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF4F46E5), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]),
  );
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;
  const _SaveButton({required this.isSaving, required this.isEditing, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 48,
    child: ElevatedButton.icon(
      onPressed: isSaving ? null : onPressed,
      icon: isSaving ? sSavingIndicator() : Icon(isEditing ? Icons.update_rounded : Icons.save_rounded, size: 18),
      label: Text(isSaving ? 'Saving…' : (isEditing ? 'Update' : 'Assign'), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
    ),
  );
}

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;
  const _ListHeader({required this.title, required this.count});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    sectionHeader(title),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
      child: Text('$count records', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600))),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 34, height: 34,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center, child: Icon(icon, size: 17, color: color)));
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFDC2626).withValues(alpha: 0.08),
      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFDC2626)))),
    ]),
  );
}
