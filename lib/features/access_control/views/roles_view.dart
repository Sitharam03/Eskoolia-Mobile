import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../controllers/role_controller.dart';
import '../../../core/routes/app_routes.dart';

const _kPri = Color(0xFF6D28D9);
const _kSec = Color(0xFF7C3AED);
const _kVio = Color(0xFF6366F1);

Color _accentFor(String name) {
  if (name.isEmpty) return _kPri;
  final code = name.codeUnitAt(0) % 6;
  const palette = [
    Color(0xFF6D28D9), Color(0xFF6366F1), Color(0xFF0EA5E9),
    Color(0xFF14B8A6), Color(0xFFF59E0B), Color(0xFFEC4899),
  ];
  return palette[code];
}

IconData _iconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('admin')) return Icons.admin_panel_settings_rounded;
  if (n.contains('teacher') || n.contains('staff')) return Icons.school_rounded;
  if (n.contains('student') || n.contains('parent')) return Icons.face_rounded;
  if (n.contains('account') || n.contains('finance')) return Icons.account_balance_rounded;
  if (n.contains('librari')) return Icons.local_library_rounded;
  if (n.contains('super')) return Icons.verified_user_rounded;
  return Icons.shield_rounded;
}

class RolesView extends GetView<RoleController> {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Role Management',
      body: Column(
        children: [
          _buildNavTabs(),
          _buildSearchBar(),
          Expanded(child: _buildRoleList()),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kPri, _kVio]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showRoleBottomSheet(context),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text('Add Role', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAV TABS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNavTabs() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F3FF)],
        ),
        boxShadow: [
          BoxShadow(color: _kVio.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _navChip('Roles', AppRoutes.roles, isActive: true),
          const SizedBox(width: 8),
          _navChip('Assign Permission', AppRoutes.assignPermissionRoot),
          const SizedBox(width: 8),
          _navChip('Login Permission', AppRoutes.loginPermission),
          const SizedBox(width: 8),
          _navChip('Due Fees', AppRoutes.dueFeesLoginPermission),
        ]),
      ),
    );
  }

  Widget _navChip(String label, String route, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (!isActive) Get.toNamed(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [_kPri, _kVio])
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: isActive ? null : Border.all(color: _kVio.withValues(alpha: 0.12)),
          boxShadow: isActive
              ? [BoxShadow(color: _kPri.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Text(label, style: GoogleFonts.poppins(
          fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? Colors.white : const Color(0xFF6B7280),
        )),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kVio.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: _kVio.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: 'Search roles...',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
            prefixIcon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [_kPri, _kVio]).createShader(bounds),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: false,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROLE LIST
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRoleList() {
    return Obx(() {
      if (controller.isLoading.value) return const SchoolLoader();
      if (controller.filteredRoles.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_kPri.withValues(alpha: 0.12), _kVio.withValues(alpha: 0.06)]),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_rounded, size: 40, color: _kPri.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('No roles found', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
          const SizedBox(height: 4),
          Text('Tap "Add Role" to create one', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
        ]));
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
        itemCount: controller.filteredRoles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _RoleCard(
          role: controller.filteredRoles[index],
          onPermissions: () => Get.toNamed('${AppRoutes.assignPermission}/${controller.filteredRoles[index].id}'),
          onEdit: () {
            controller.startEdit(controller.filteredRoles[index]);
            _showRoleBottomSheet(context);
          },
          onDelete: () => _confirmDelete(context, controller.filteredRoles[index]),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  void _confirmDelete(BuildContext context, dynamic role) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
          ),
          const SizedBox(width: 10),
          Text('Delete Role', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Text('Are you sure you want to delete "${role.name}"?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280), height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFB91C1C)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ElevatedButton(
              onPressed: () { Get.back(); controller.deleteRole(role.id); },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F3FF), Colors.white],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kPri, _kVio]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                const SizedBox(height: 18),
                Row(children: [
                  Container(width: 4, height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_kPri, _kVio]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                    controller.editingRoleId.value != null ? 'Edit Role' : 'Create New Role',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                  )),
                ]),
                const SizedBox(height: 22),
                Text('Role Name *', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _kPri.withValues(alpha: 0.6), letterSpacing: 0.3)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Enter role name',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _kPri.withValues(alpha: 0.15))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _kPri.withValues(alpha: 0.15))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _kPri, width: 1.8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Obx(() {
                    if (controller.editingRoleId.value != null) {
                      return Expanded(child: OutlinedButton(
                        onPressed: () { controller.resetForm(); Get.back(); },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: _kPri.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
                      ));
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(() => controller.editingRoleId.value != null ? const SizedBox(width: 12) : const SizedBox.shrink()),
                  Expanded(
                    child: Obx(() => Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_kPri, _kVio]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: _kPri.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isSaving.value ? null : () { controller.submit(); Get.back(); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Save Role', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    )),
                  ),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => controller.resetForm());
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROLE CARD — modern design with unique accent per role
// ═══════════════════════════════════════════════════════════════════════════════

class _RoleCard extends StatelessWidget {
  final dynamic role;
  final VoidCallback onPermissions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RoleCard({required this.role, required this.onPermissions, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isSystem = role.isSystem as bool;
    final accent = _accentFor(role.name as String);
    final roleIcon = _iconFor(role.name as String);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, accent.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(right: -16, top: -16, child: Container(width: 60, height: 60,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.06)))),
        Positioned(left: -10, bottom: -10, child: Container(width: 40, height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.04)))),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // ── Role icon badge ──
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [accent, accent.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(roleIcon, color: Colors.white, size: 24),
                  const SizedBox(height: 1),
                  Text((role.name as String).isNotEmpty ? (role.name as String)[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
                ]),
              ),
              const SizedBox(width: 14),
              // ── Name + badge ──
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(role.name as String,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                // System / Custom badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      (isSystem ? _kPri : const Color(0xFF22C55E)).withValues(alpha: 0.12),
                      (isSystem ? _kPri : const Color(0xFF22C55E)).withValues(alpha: 0.05),
                    ]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (isSystem ? _kPri : const Color(0xFF22C55E)).withValues(alpha: 0.25)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isSystem ? Icons.lock_rounded : Icons.tune_rounded, size: 11,
                      color: isSystem ? _kPri : const Color(0xFF22C55E)),
                    const SizedBox(width: 4),
                    Text(isSystem ? 'System Role' : 'Custom Role',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                        color: isSystem ? _kPri : const Color(0xFF22C55E))),
                  ]),
                ),
              ])),
            ]),
            const SizedBox(height: 14),
            // ── Gradient divider ──
            Container(height: 1, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                accent.withValues(alpha: 0.0), accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.0),
              ]),
            )),
            const SizedBox(height: 12),
            // ── Action buttons ──
            Row(children: [
              Expanded(child: _ActionBtn(
                label: 'Permissions', icon: Icons.lock_open_rounded,
                color: _kPri, onTap: onPermissions,
              )),
              const SizedBox(width: 8),
              _SmallAction(icon: Icons.edit_rounded, color: const Color(0xFF0EA5E9), onTap: onEdit),
              if (!isSystem) ...[
                const SizedBox(width: 6),
                _SmallAction(icon: Icons.delete_rounded, color: const Color(0xFFDC2626), onTap: onDelete),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

class _SmallAction extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _SmallAction({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38, alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: 17, color: color),
    ),
  );
}
