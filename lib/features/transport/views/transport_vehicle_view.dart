import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/transport_vehicle_controller.dart';
import '../models/transport_models.dart';
import '_transport_nav_tabs.dart';

class TransportVehicleView extends StatelessWidget {
  const TransportVehicleView({super.key});

  TransportVehicleController get _c =>
      Get.find<TransportVehicleController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transport',
      body: Column(children: [
        const TransportNavTabs(activeRoute: AppRoutes.transportVehicles),
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
                  _VehicleList(c: _c),
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
  final TransportVehicleController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.vehicles.length;
      final active = c.vehicles.where((v) => v.activeStatus).length;
      final withDriver = c.vehicles.where((v) => v.driverId != null).length;
      return Row(children: [
        _StatTile(value: '$total', label: 'Total', color: const Color(0xFF4F46E5), icon: Icons.directions_bus_rounded),
        const SizedBox(width: 8),
        _StatTile(value: '$active', label: 'Active', color: const Color(0xFF059669), icon: Icons.check_circle_outline_rounded),
        const SizedBox(width: 8),
        _StatTile(value: '$withDriver', label: 'With Driver', color: const Color(0xFF8B5CF6), icon: Icons.person_rounded),
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
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color)),
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
  final TransportVehicleController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Obx(() => Column(children: [
            _formHeader(
              icon: c.editingId.value != null ? Icons.edit_rounded : Icons.directions_bus_rounded,
              title: c.editingId.value != null ? 'Edit Vehicle' : 'Add Vehicle',
              subtitle: c.editingId.value != null ? 'Update vehicle info' : 'Register a new vehicle',
              onCancel: c.editingId.value != null ? c.cancelEdit : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    sFieldLabel('Vehicle No *'),
                    const SizedBox(height: 6),
                    sTextField(controller: c.vehicleNoCtrl, hint: 'e.g. ABC-1234'),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    sFieldLabel('Model *'),
                    const SizedBox(height: 6),
                    sTextField(controller: c.vehicleModelCtrl, hint: 'Toyota Coaster'),
                  ])),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    sFieldLabel('Made Year'),
                    const SizedBox(height: 6),
                    sTextField(controller: c.madeYearCtrl, hint: '2023', keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    sFieldLabel('Driver'),
                    const SizedBox(height: 6),
                    sDropdown<int>(
                      value: c.selectedDriverId.value,
                      hint: 'Select Driver',
                      items: c.drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.displayLabel, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => c.selectedDriverId.value = v,
                    ),
                  ])),
                ]),
                const SizedBox(height: 14),
                sFieldLabel('Note'),
                const SizedBox(height: 6),
                sTextField(controller: c.noteCtrl, hint: 'Optional notes', maxLines: 2),
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

class _VehicleList extends StatelessWidget {
  final TransportVehicleController c;
  const _VehicleList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = c.drivers.length;
      final items = c.filteredVehicles;
      if (items.isEmpty) {
        return sEmptyState('No vehicles found', Icons.directions_bus_outlined);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ListHeader(title: 'Vehicles', count: items.length),
        const SizedBox(height: 10),
        ...items.map((v) => _VehicleCard(
          vehicle: v,
          driverName: v.driverName.isNotEmpty ? v.driverName : c.driverName(v.driverId),
          onEdit: () => c.startEdit(v),
          onDelete: () => showDialog(context: context, builder: (_) => sDeleteDialog(
            context: context, message: 'Delete vehicle "${v.vehicleNo}"?',
            onConfirm: () => c.delete(v.id))),
        )),
      ]);
    });
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final String driverName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _VehicleCard({required this.vehicle, required this.driverName, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: vehicle.activeStatus ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.directions_bus_rounded, size: 20, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(vehicle.vehicleNo, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    Text(vehicle.vehicleModel, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                  ])),
                  sBadge(vehicle.activeStatus ? 'Active' : 'Inactive',
                      vehicle.activeStatus ? const Color(0xFF059669) : const Color(0xFF6B7280)),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 16, runSpacing: 6, children: [
                  if (vehicle.madeYear != null)
                    _InfoChip(icon: Icons.calendar_today_rounded, text: '${vehicle.madeYear}'),
                  _InfoChip(icon: Icons.person_rounded, text: driverName.isNotEmpty ? driverName : 'No Driver'),
                  if (vehicle.note.isNotEmpty)
                    _InfoChip(icon: Icons.note_rounded, text: vehicle.note),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _ActionBtn(icon: Icons.edit_rounded, color: const Color(0xFF0EA5E9), onTap: onEdit),
                  const SizedBox(width: 8),
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

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _formHeader({
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onCancel,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
        ])),
        if (onCancel != null)
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)),
            ),
          ),
      ]),
    );

class _ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ActiveToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, size: 22,
            color: value ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Expanded(child: Text('Active', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151), fontWeight: FontWeight.w500))),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF4F46E5), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ]),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;
  const _SaveButton({required this.isSaving, required this.isEditing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving ? sSavingIndicator() : Icon(isEditing ? Icons.update_rounded : Icons.save_rounded, size: 18),
        label: Text(isSaving ? 'Saving…' : (isEditing ? 'Update' : 'Save'),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;
  const _ListHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      sectionHeader(title),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
        child: Text('$count records', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 4),
      Text(text, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFDC2626)))),
      ]),
    );
  }
}
