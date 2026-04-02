import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_designation_controller.dart';
import '../models/hr_models.dart';
import '_hr_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

// ── Designation colours ──────────────────────────────────────────────────────
const _kPri = Color(0xFF0EA5E9);
const _kSec = Color(0xFF0284C7);
const _kVio = Color(0xFF6366F1);

// Maps designation initial to a unique accent colour for variety
Color _accentFor(String name) {
  if (name.isEmpty) return _kPri;
  final code = name.codeUnitAt(0) % 6;
  const palette = [
    Color(0xFF6366F1), // indigo
    Color(0xFF0EA5E9), // sky
    Color(0xFF7C3AED), // violet
    Color(0xFF14B8A6), // teal
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
  ];
  return palette[code];
}

class HrDesignationView extends StatelessWidget {
  const HrDesignationView({super.key});
  HrDesignationController get _c => Get.find<HrDesignationController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(children: [
        const HrNavTabs(activeRoute: '/hr/designations'),
        Expanded(child: Obx(() {
          if (_c.isLoading.value) {
            return const SchoolLoader();
          }
          return RefreshIndicator(
            color: _kPri,
            onRefresh: _c.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
              child: Column(children: [
                _StatsRow(c: _c),
                const SizedBox(height: 14),
                _FormCard(c: _c),
                Obx(() => _c.errorMsg.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ErrorBanner(msg: _c.errorMsg.value))
                    : const SizedBox.shrink()),
                const SizedBox(height: 16),
                sSearchBar(
                  hint: 'Search designations…',
                  onChanged: (v) => _c.searchQuery.value = v,
                ),
                const SizedBox(height: 14),
                _DesigList(c: _c),
              ]),
            ),
          );
        })),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS ROW — glass cards with gradient icons
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final HrDesignationController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final total = c.designations.length;
        final active = c.designations.where((d) => d.isActive).length;
        return Row(children: [
          _Stat(
              value: '$total',
              label: 'Total',
              color: _kVio,
              icon: Icons.work_outline_rounded),
          const SizedBox(width: 8),
          _Stat(
              value: '$active',
              label: 'Active',
              color: const Color(0xFF22C55E),
              icon: Icons.verified_rounded),
          const SizedBox(width: 8),
          _Stat(
              value: '${total - active}',
              label: 'Inactive',
              color: const Color(0xFF9CA3AF),
              icon: Icons.pause_circle_rounded),
        ]);
      });
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _Stat(
      {required this.value,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
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

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD — gradient header + glass inputs
// ═══════════════════════════════════════════════════════════════════════════════

class _FormCard extends StatelessWidget {
  final HrDesignationController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Obx(() => Column(children: [
              _FormHeader(
                icon: c.editingId.value != null
                    ? Icons.edit_rounded
                    : Icons.add_circle_rounded,
                title: c.editingId.value != null
                    ? 'Edit Designation'
                    : 'New Designation',
                subtitle: 'Manage staff job titles & roles',
                onCancel: c.editingId.value != null ? c.cancelEdit : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Designation Name *'),
                    const SizedBox(height: 6),
                    sTextField(
                        controller: c.nameCtrl,
                        hint: 'e.g. Senior Teacher'),
                    const SizedBox(height: 14),
                    sFieldLabel('Department'),
                    const SizedBox(height: 6),
                    Obx(() => sDropdown<int>(
                          value: c.selectedDepartmentId.value,
                          hint: 'Select department (optional)',
                          items: c.departments
                              .map((d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.name,
                                      style:
                                          GoogleFonts.inter(fontSize: 14))))
                              .toList(),
                          onChanged: (v) =>
                              c.selectedDepartmentId.value = v,
                        )),
                    const SizedBox(height: 14),
                    Obx(() => _Toggle(
                        label: 'Active',
                        value: c.isActive.value,
                        onChanged: (v) => c.isActive.value = v)),
                    const SizedBox(height: 16),
                    Obx(() => _SaveBtn(
                        isSaving: c.isSaving.value,
                        isEditing: c.editingId.value != null,
                        onPressed: c.save)),
                  ],
                ),
              ),
            ])),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGNATION LIST + CARD — modern redesign
// ═══════════════════════════════════════════════════════════════════════════════

class _DesigList extends StatelessWidget {
  final HrDesignationController c;
  const _DesigList({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final items = c.filtered;
        if (items.isEmpty) {
          return sEmptyState(
              'No designations found', Icons.work_off_rounded);
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ListHeader(title: 'Designations', count: items.length),
              const SizedBox(height: 10),
              ...items.map((d) => _DesigCard(
                    desig: d,
                    onEdit: () => c.startEdit(d),
                    onDelete: () => showDialog(
                      context: context,
                      builder: (_) => sDeleteDialog(
                        context: context,
                        message: 'Delete "${d.name}"?',
                        onConfirm: () => c.delete(d.id),
                      ),
                    ),
                  )),
            ]);
      });
}

class _DesigCard extends StatelessWidget {
  final Designation desig;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _DesigCard({
    required this.desig,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(desig.name);
    final isActive = desig.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, accent.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -12,
            bottom: -12,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // ── Designation icon ──
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, accent.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(height: 1),
                    Text(
                      desig.name.isNotEmpty
                          ? desig.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desig.name,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      // Department chip
                      if (desig.departmentName.isNotEmpty)
                        _InfoChip(
                          icon: Icons.business_rounded,
                          label: desig.departmentName,
                          color: _kSec,
                        ),
                      // Status chip
                      _InfoChip(
                        icon: isActive
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        label: isActive ? 'Active' : 'Inactive',
                        color: isActive
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9CA3AF),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── Actions ──
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionBtn(
                      icon: Icons.edit_rounded,
                      color: _kPri,
                      onTap: onEdit),
                  const SizedBox(height: 6),
                  _ActionBtn(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFFDC2626),
                      onTap: onDelete),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INFO CHIP
// ═══════════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onCancel;
  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _kPri.withValues(alpha: 0.08),
              _kVio.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPri, _kVio],
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: _kPri.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827))),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 15, color: Color(0xFFDC2626)),
              ),
            ),
        ]),
      );
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(
              color: (value ? _kPri : const Color(0xFF9CA3AF))
                  .withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(
            value
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_rounded,
            size: 24,
            color: value ? _kPri : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _kPri,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),
      );
}

class _SaveBtn extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;
  const _SaveBtn(
      {required this.isSaving,
      required this.isEditing,
      required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kPri, _kVio]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kPri.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : onPressed,
            icon: isSaving
                ? sSavingIndicator()
                : Icon(
                    isEditing ? Icons.update_rounded : Icons.save_rounded,
                    size: 18),
            label: Text(
              isSaving ? 'Saving…' : (isEditing ? 'Update' : 'Save'),
              style:
                  GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
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
            gradient: LinearGradient(
              colors: [
                _kVio.withValues(alpha: 0.12),
                _kVio.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kVio.withValues(alpha: 0.2)),
          ),
          child: Text('$count records',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _kVio,
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: color),
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.10),
              const Color(0xFFDC2626).withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Color(0xFFDC2626), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFDC2626))),
          ),
        ]),
      );
}
