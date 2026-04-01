import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import 'module_popup.dart';

// ── Dashboard View ─────────────────────────────────────────────────────────────

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {

  late final AnimationController _entranceCtrl;
  late final AnimationController _bellCtrl;

  // Welcome card is always visible

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Welcome card stays visible permanently
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _bellCtrl.dispose();
    // no timer to cancel
    super.dispose();
  }

  Future<void> _logout() async {
    await StorageService.to.clearAuthTokens();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      bottomNavigationBar: _BottomBar(
        onReports: () => ModulePopup.show(context, kReportsModule),
        onSettings: () => ModulePopup.show(context, kSettingsModule),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildWelcomeAnimated()),
              _buildSectionLabel('Modules'),
              _buildGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          const Positioned.fill(child: _FloatingParticles()),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const _EskooliaLogo(),
          ),
          const SizedBox(width: 10),
          Text(
            'eSkoolia',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        _PulseBell(controller: _bellCtrl),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            onTap: _logout,
            child: Container(
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.4),
                const Color(0xFF7C3AED).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Welcome Card ──────────────────────────────────────────────────────────────

  Widget _buildWelcomeAnimated() {
    return _buildWelcomeCard();
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entranceCtrl,
          curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _entranceCtrl,
          curve: const Interval(0, 0.4, curve: Curves.easeOutCubic)),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 16, 14, 4),
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF7C3AED), Color(0xFF0EA5E9)],
              stops: [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$greeting! 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'Academic Year 2025–26',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // child: Text(
                      //   'Dismiss',
                      //   style: GoogleFonts.inter(
                      //     fontSize: 10,
                      //     color: Colors.white.withValues(alpha: 0.9),
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Label & Grid ──────────────────────────────────────────────────────

  SliverToBoxAdapter _buildSectionLabel(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final start = (0.10 + i * 0.055).clamp(0.0, 0.72);
            final end = (start + 0.30).clamp(0.0, 1.0);
            final fade = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                  parent: _entranceCtrl,
                  curve: Interval(start, end, curve: Curves.easeOut)),
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                  parent: _entranceCtrl,
                  curve: Interval(start, end, curve: Curves.easeOutCubic)),
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: _ModuleCard(
                  module: kDashboardModules[i],
                  index: i,
                  onTap: () =>
                      ModulePopup.show(context, kDashboardModules[i]),
                ),
              ),
            );
          },
          childCount: kDashboardModules.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }
}

// ── Module Card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final DashboardModule module;
  final VoidCallback onTap;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.onTap,
    required this.index,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with TickerProviderStateMixin {
  late final AnimationController _tap;
  late final Animation<double> _scale;

  // Shine sweep
  late final AnimationController _shineCtrl;
  late final Animation<double> _shineAnim;
  bool _disposed = false;

  // Glow pulse on icon
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // Tap scale
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _tap, curve: Curves.easeIn),
    );

    // Shine sweep (650ms forward, then 4.5s pause, repeat)
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _shineAnim = CurvedAnimation(parent: _shineCtrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: 1800 + widget.index * 160), () {
      if (!_disposed) _repeatShine();
    });

    // Subtle glow pulse on icon box (1.2s, repeating)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  void _repeatShine() {
    _shineCtrl.forward(from: 0).then((_) async {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 4500));
      if (!_disposed) _repeatShine();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _tap.dispose();
    _shineCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapCancel: () => _tap.reverse(),
        onTapUp: (_) {
          _tap.reverse();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: m.gradient,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: m.iconColor.withValues(
                    alpha: 0.18 + _glowAnim.value * 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: m.iconColor.withValues(
                      alpha: 0.08 + _glowAnim.value * 0.14),
                  blurRadius: 12 + _glowAnim.value * 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Bottom-right decorative circle
              Positioned(
                right: -12,
                bottom: -12,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.iconColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Top-left decorative dot cluster
              Positioned(
                left: -8,
                top: -8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.iconColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Card content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon with glow ring — centred
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, __) => Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: m.iconColor.withValues(
                                alpha: 0.06 + _glowAnim.value * 0.1),
                          ),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: m.iconColor,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: m.iconColor.withValues(
                                        alpha: 0.28 + _glowAnim.value * 0.18),
                                    blurRadius: 8 + _glowAnim.value * 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child:
                                  Icon(m.icon, color: Colors.white, size: 19),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        m.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${m.items.length} items',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: m.iconColor.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Shine sweep overlay
              AnimatedBuilder(
                animation: _shineAnim,
                builder: (_, __) {
                  if (_shineCtrl.value == 0.0) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LayoutBuilder(builder: (ctx, box) {
                          final w = box.maxWidth;
                          final pos = _shineAnim.value * (w + 50) - 25;
                          return Stack(children: [
                            Positioned(
                              left: pos - 18,
                              top: 0,
                              bottom: 0,
                              width: 36,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationZ(0.2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.45),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulse Bell ─────────────────────────────────────────────────────────────────

class _PulseBell extends StatelessWidget {
  final AnimationController controller;
  const _PulseBell({required this.controller});

  @override
  Widget build(BuildContext context) {
    final rotate = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: rotate,
          builder: (_, __) => Transform.rotate(
            angle: rotate.value,
            alignment: Alignment.topCenter,
            child: IconButton(
              icon: const Icon(Icons.notifications_rounded,
                  color: Colors.white, size: 24),
              splashRadius: 20,
              onPressed: () {},
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onReports;
  final VoidCallback onSettings;

  const _BottomBar({required this.onReports, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                selected: false,
                onTap: onReports,
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                selected: false,
                onTap: onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── eSkoolia Logo ──────────────────────────────────────────────────────────────

class _EskooliaLogo extends StatelessWidget {
  const _EskooliaLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/eSkoolia_logo.jpeg',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ── Floating Particles ─────────────────────────────────────────────────────────

class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _particles = [
    (Icons.menu_book_rounded, 0.07, Color(0xFF6366F1), 18.0, 0.0),
    (Icons.school_rounded, 0.87, Color(0xFF22C55E), 16.0, 0.18),
    (Icons.calculate_rounded, 0.18, Color(0xFFF97316), 14.0, 0.35),
    (Icons.science_rounded, 0.73, Color(0xFF0EA5E9), 16.0, 0.5),
    (Icons.brush_rounded, 0.48, Color(0xFFF59E0B), 14.0, 0.62),
    (Icons.music_note_rounded, 0.33, Color(0xFFEF4444), 15.0, 0.76),
    (Icons.sports_soccer_rounded, 0.62, Color(0xFF84CC16), 13.0, 0.22),
    (Icons.computer_rounded, 0.91, Color(0xFFA855F7), 15.0, 0.55),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Stack(
            children: _particles.map((p) {
              final (icon, xFrac, color, iconSize, phase) = p;
              final t = (_ctrl.value + phase) % 1.0;
              final y = h * (1.0 - t * 0.9);
              final opacity = t < 0.15
                  ? t / 0.15
                  : t > 0.75
                      ? (1.0 - t) / 0.25
                      : 1.0;
              return Positioned(
                left: xFrac * w,
                top: y,
                child: Opacity(
                  opacity: (opacity * 0.18).clamp(0.0, 1.0),
                  child: Icon(icon, color: color, size: iconSize),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: selected
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
