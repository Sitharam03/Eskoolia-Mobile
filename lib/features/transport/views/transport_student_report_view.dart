import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/transport_student_report_controller.dart';
import '../models/transport_models.dart';
import '_transport_nav_tabs.dart';

class TransportStudentReportView extends StatelessWidget {
  const TransportStudentReportView({super.key});

  TransportStudentReportController get _c =>
      Get.find<TransportStudentReportController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transport',
      body: Column(children: [
        const TransportNavTabs(activeRoute: AppRoutes.transportStudentReport),
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
                  Obx(() {
                    if (_c.errorMsg.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ErrorBanner(msg: _c.errorMsg.value),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _FilterCard(c: _c),
                  const SizedBox(height: 16),
                  _SummaryRow(c: _c),
                  const SizedBox(height: 12),
                  _StudentList(c: _c),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ── Filter Card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final TransportStudentReportController c;
  const _FilterCard({required this.c});

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
                  child: const Icon(Icons.filter_list_rounded, size: 18, color: Color(0xFF4F46E5))),
                const SizedBox(width: 10),
                Expanded(child: Text('Filter Report', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF111827)))),
                TextButton.icon(
                  onPressed: c.clearFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF4F46E5)),
                  label: Text('Reset', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sFieldLabel('Filter by Route'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: c.routeFilter.value,
                  hint: 'All Routes',
                  items: c.routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.title, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => c.routeFilter.value = v,
                ),
                const SizedBox(height: 14),
                sFieldLabel('Filter by Vehicle'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: c.vehicleFilter.value,
                  hint: 'All Vehicles',
                  items: c.vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.vehicleNo, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => c.vehicleFilter.value = v,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Active Students Only', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151), fontWeight: FontWeight.w500))),
                    Switch(value: c.activeOnly.value, onChanged: (v) => c.activeOnly.value = v,
                      activeColor: const Color(0xFF4F46E5), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ]),
                ),
              ]),
            ),
          ])),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final TransportStudentReportController c;
  const _SummaryRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filtered = c.filteredStudents;
      final withRoute = filtered.where((s) => s.transportRouteTitle.isNotEmpty).length;
      final withVehicle = filtered.where((s) => s.vehicleNo.isNotEmpty).length;
      return Row(children: [
        _SummaryTile(value: '${filtered.length}', label: 'Total', color: const Color(0xFF4F46E5), icon: Icons.people_rounded),
        const SizedBox(width: 8),
        _SummaryTile(value: '$withRoute', label: 'With Route', color: const Color(0xFF8B5CF6), icon: Icons.route_rounded),
        const SizedBox(width: 8),
        _SummaryTile(value: '$withVehicle', label: 'With Vehicle', color: const Color(0xFF059669), icon: Icons.directions_bus_rounded),
      ]);
    });
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _SummaryTile({required this.value, required this.label, required this.color, required this.icon});

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

// ── Student List ──────────────────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final TransportStudentReportController c;
  const _StudentList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = c.routes.length;
      final __ = c.vehicles.length;
      final items = c.filteredStudents;
      if (items.isEmpty) return sEmptyState('No students match the filter', Icons.people_outline_rounded);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          sectionHeader('Students'),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
            child: Text('${items.length} students', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        ...items.map((s) => _StudentCard(student: s)),
      ]);
    });
  }
}

class _StudentCard extends StatelessWidget {
  final StudentTransport student;
  const _StudentCard({required this.student});

  String get _initials {
    final parts = student.fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = student.transportRouteTitle.isNotEmpty;
    final hasVehicle = student.vehicleNo.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: student.isActive ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [const Color(0xFF4F46E5), const Color(0xFF4F46E5).withValues(alpha: 0.65)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(_initials, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(student.fullName.isNotEmpty ? student.fullName : 'Student',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 2),
                  Text(student.admissionNo, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    if (hasRoute)
                      _TagChip(icon: Icons.route_rounded, text: student.transportRouteTitle, color: const Color(0xFF8B5CF6))
                    else
                      _TagChip(icon: Icons.route_rounded, text: 'No Route', color: const Color(0xFF9CA3AF)),
                    if (hasVehicle)
                      _TagChip(icon: Icons.directions_bus_rounded, text: student.vehicleNo, color: const Color(0xFF4F46E5))
                    else
                      _TagChip(icon: Icons.directions_bus_rounded, text: 'No Vehicle', color: const Color(0xFF9CA3AF)),
                  ]),
                ])),
                sBadge(student.isActive ? 'Active' : 'Inactive',
                    student.isActive ? const Color(0xFF059669) : const Color(0xFF6B7280)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _TagChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
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
