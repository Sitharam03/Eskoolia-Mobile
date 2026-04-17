import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import 'module_popup.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

const _kBlueDark = Color(0xFF2D3A8C);
const _kBlueLight = Color(0xFF5B6AD4);
const _kBgTop = Color(0xFF1E2A6E);
const _kBgMid = Color(0xFF3B4FC2);
const _kBgBot = Color(0xFFA8B4F0);
const _kNavBg = Color(0xFF1B1F3B);
const _kNavActive = Color(0xFF4F6BF6);

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _bellCtrl;
  late final AnimationController _starsCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _bellCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))
      ..repeat();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _bellCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await StorageService.to.clearAuthTokens();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEB),
        bottomNavigationBar: _BottomBar(
          onChat: () => Get.toNamed(AppRoutes.chat),
          onSettings: () => ModulePopup.show(context, kSettingsModule),
        ),
        body: Stack(
          children: [
            // ── Content (first so animations render ON TOP) ──
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildWelcome()),
                _buildLabel('Modules'),
                _buildGrid(),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
            // ── Animated floating school icons (ON TOP of content, but IgnorePointer) ──
            Positioned.fill(
              child: IgnorePointer(child: _FloatingSchoolIcons(ctrl: _starsCtrl)),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 64,
      title: Row(children: [
        // Logo
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF2A3580),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/eSkoolia_logo.jpeg',
                width: 42, height: 42, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 10),
        Text('eSkoolia',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: const Color(0xFF1A1A2E))),
      ]),
      actions: [
        // Bell
        _PulseBell(ctrl: _bellCtrl),
        const SizedBox(width: 6),
        // Logout button
        GestureDetector(
          onTap: _logout,
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.logout_rounded, color: Color(0xFF1A1A2E), size: 18),
              const SizedBox(width: 6),
              Text('Logout',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
            ]),
          ),
        ),
      ],
    );
  }

  // ── WELCOME CARD ────────────────────────────────────────────────────────────

  Widget _buildWelcome() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning!'
        : hour < 17
            ? 'Good Afternoon!'
            : 'Good Evening!';

    final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl, curve: const Interval(0, 0.4, curve: Curves.easeOut)));
    final slide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: const Interval(0, 0.4, curve: Curves.easeOutCubic)));

    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${now.day} ${months[now.month - 1]}, ${now.year}';

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF), Color(0xFFFECDD3)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF9A9E).withValues(alpha: 0.3),
                    blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: greeting pill + date ──
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('👋', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(greeting, style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C2D12))),
                    ]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(dateStr, style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C2D12).withValues(alpha: 0.7))),
                  ),
                ]),
                const SizedBox(height: 16),
                // ── Name ──
                Text('Welcome Back,', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: const Color(0xFF7C2D12).withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Text('Alex Johnson ✨', style: GoogleFonts.poppins(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E), height: 1.1)),
                const SizedBox(height: 14),
                // ── Bottom info row ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Text('🎓', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Academic Year 2025-26', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C2D12))),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildLabel(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E))),
      ),
    );
  }

  // ── MODULE GRID ─────────────────────────────────────────────────────────────

  Widget _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final start = (0.10 + i * 0.05).clamp(0.0, 0.72);
            final end = (start + 0.28).clamp(0.0, 1.0);
            final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                parent: _entranceCtrl, curve: Interval(start, end, curve: Curves.easeOut)));
            final slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: _entranceCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)));
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: _ModuleCard(
                  module: kDashboardModules[i],
                  index: i,
                  onTap: () => ModulePopup.show(context, kDashboardModules[i]),
                ),
              ),
            );
          },
          childCount: kDashboardModules.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE CARD — white/light rounded card with icon and module name
// ═══════════════════════════════════════════════════════════════════════════════

class _ModuleCard extends StatefulWidget {
  final DashboardModule module;
  final VoidCallback onTap;
  final int index;
  const _ModuleCard({required this.module, required this.onTap, required this.index});
  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _tap;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(vsync: this, duration: const Duration(milliseconds: 80),
        reverseDuration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _tap, curve: Curves.easeIn));
  }

  @override
  void dispose() { _tap.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final hasEmoji = m.emoji.isNotEmpty;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapCancel: () => _tap.reverse(),
        onTapUp: (_) { _tap.reverse(); widget.onTap(); },
        child: Column(
          children: [
            // ── Square white card with emoji ──
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8F6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: hasEmoji
                        ? Text(m.emoji, style: const TextStyle(fontSize: 44))
                        : Icon(m.icon, color: m.iconColor, size: 38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // ── Module name below card ──
            Text(
              m.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PULSE BELL
// ═══════════════════════════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2,
          size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8,
          size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4,
          size.width * 0.6, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.85, size.height * 1.0,
          size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatMini extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _StatMini({required this.emoji, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.10)),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
        ]),
      ),
    );
  }
}

class _BannerPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BannerPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 5),
        Text(text, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.85))),
      ]),
    );
  }
}

class _PulseBell extends StatelessWidget {
  final AnimationController ctrl;
  const _PulseBell({required this.ctrl});
  @override
  Widget build(BuildContext context) {
    final rot = Tween<double>(begin: -0.1, end: 0.1)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
    return Stack(clipBehavior: Clip.none, children: [
      AnimatedBuilder(animation: rot, builder: (_, __) => Transform.rotate(
        angle: rot.value, alignment: Alignment.topCenter,
        child: IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A2E), size: 24),
          splashRadius: 20, onPressed: () {},
        ),
      )),
      Positioned(right: 12, top: 12, child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5)),
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM NAV BAR — matching dashboard theme with emoji icons
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  final VoidCallback onChat;
  final VoidCallback onSettings;
  const _BottomBar({required this.onChat, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _kBgBot.withValues(alpha: 0.5)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: _kBlueDark.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(children: [
            _NavItem(emoji: '🏠', label: 'Dashboard', active: true, onTap: () {}),
            _NavItem(emoji: '💬', label: 'Chat', active: false, onTap: onChat),
            _NavItem(emoji: '⚙️', label: 'Settings', active: false, onTap: onSettings),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.emoji, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: TextStyle(fontSize: active ? 32 : 26)),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? _kBlueDark : const Color(0xFF9CA3AF),
          )),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOATING ANIMATED SCHOOL ICONS — gentle floating upward, school-themed
// ═══════════════════════════════════════════════════════════════════════════════

class _FloatingSchoolIcons extends StatelessWidget {
  final AnimationController ctrl;
  const _FloatingSchoolIcons({required this.ctrl});

  static double _sin(double x) {
    x = x % 6.283;
    if (x > 3.1416) x -= 6.283;
    final x2 = x * x;
    return x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0));
  }

  static const _items = [
    (Icons.menu_book_rounded,       0.06, 26.0, 0.00, Color(0xFF6366F1)),
    (Icons.school_rounded,          0.88, 24.0, 0.12, Color(0xFF22C55E)),
    (Icons.calculate_rounded,       0.20, 22.0, 0.25, Color(0xFFF97316)),
    (Icons.science_rounded,         0.72, 24.0, 0.38, Color(0xFF0EA5E9)),
    (Icons.brush_rounded,           0.46, 20.0, 0.50, Color(0xFFF59E0B)),
    (Icons.music_note_rounded,      0.32, 22.0, 0.62, Color(0xFFEF4444)),
    (Icons.sports_soccer_rounded,   0.60, 18.0, 0.74, Color(0xFF84CC16)),
    (Icons.computer_rounded,        0.92, 22.0, 0.86, Color(0xFFA855F7)),
    (Icons.directions_bus_rounded,  0.14, 24.0, 0.18, Color(0xFFEA580C)),
    (Icons.auto_stories_rounded,    0.78, 20.0, 0.42, Color(0xFF14B8A6)),
    (Icons.emoji_events_rounded,    0.52, 18.0, 0.56, Color(0xFFD97706)),
    (Icons.send_rounded,            0.84, 16.0, 0.70, Color(0xFF6366F1)),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Stack(
        children: _items.map((p) {
          final (icon, xFrac, sz, phase, color) = p;
          final t = (ctrl.value + phase) % 1.0;
          final y = h * (1.0 - t * 0.85);
          final xSway = 6.0 * _sin((ctrl.value + phase) * 6.283);
          final fade = t < 0.12 ? t / 0.12 : t > 0.80 ? (1.0 - t) / 0.20 : 1.0;

          return Positioned(
            left: xFrac * w + xSway,
            top: y,
            child: Opacity(
              opacity: (fade * 0.18).clamp(0.0, 0.18),
              child: Icon(icon, color: color, size: sz),
            ),
          );
        }).toList(),
      ),
    );
  }
}
