import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routes.dart';
import '../services/storage_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE THEME — each module gets unique colors, icon & floating particle icons
// ═══════════════════════════════════════════════════════════════════════════════

class _P {
  final IconData icon;
  final double x;
  final double sz;
  final double phase;
  const _P(this.icon, this.x, this.sz, this.phase);
}

class _MTheme {
  final Color primary;
  final Color secondary;
  final List<Color> gradient;
  final Color bg;
  final IconData icon;
  final List<_P> particles;

  const _MTheme({
    required this.primary,
    required this.secondary,
    required this.gradient,
    required this.bg,
    required this.icon,
    required this.particles,
  });

  static _MTheme from(String title) {
    final t = title.toLowerCase();
    if (t.contains('student')) return _student;
    if (t.contains('academic')) return _academics;
    if (t.contains('exam')) return _exam;
    if (t.contains('fee')) return _fees;
    if (t.contains('human') || t.contains('resource')) return _hr;
    if (t.contains('account') || t.contains('finance')) return _accounts;
    if (t.contains('behaviour')) return _behaviour;
    if (t.contains('admin')) return _admin;
    if (t.contains('role') || t.contains('permission')) return _role;
    if (t.contains('library')) return _library;
    if (t.contains('transport')) return _transport;
    if (t.contains('inventory')) return _inventory;
    return _fallback;
  }
}

const _student = _MTheme(
  primary: Color(0xFF6366F1),
  secondary: Color(0xFF818CF8),
  gradient: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF7C3AED)],
  bg: Color(0xFFF5F3FF),
  icon: Icons.face_rounded,
  particles: [
    _P(Icons.face_rounded, 0.08, 18, 0.0),
    _P(Icons.school_rounded, 0.88, 16, 0.15),
    _P(Icons.backpack_rounded, 0.22, 14, 0.32),
    _P(Icons.assignment_ind_rounded, 0.72, 16, 0.48),
    _P(Icons.edit_note_rounded, 0.45, 15, 0.63),
    _P(Icons.person_rounded, 0.92, 13, 0.78),
    _P(Icons.group_rounded, 0.35, 14, 0.88),
  ],
);

const _academics = _MTheme(
  primary: Color(0xFF22C55E),
  secondary: Color(0xFF4ADE80),
  gradient: [Color(0xFF22C55E), Color(0xFF16A34A), Color(0xFF0D9488)],
  bg: Color(0xFFF0FDF4),
  icon: Icons.school_rounded,
  particles: [
    _P(Icons.menu_book_rounded, 0.07, 18, 0.0),
    _P(Icons.science_rounded, 0.85, 16, 0.18),
    _P(Icons.calculate_rounded, 0.20, 14, 0.35),
    _P(Icons.auto_stories_rounded, 0.70, 16, 0.50),
    _P(Icons.brush_rounded, 0.48, 14, 0.65),
    _P(Icons.schedule_rounded, 0.90, 15, 0.80),
    _P(Icons.lightbulb_rounded, 0.32, 13, 0.90),
  ],
);

const _exam = _MTheme(
  primary: Color(0xFFF97316),
  secondary: Color(0xFFFBBF24),
  gradient: [Color(0xFFF97316), Color(0xFFEA580C), Color(0xFFDC2626)],
  bg: Color(0xFFFFF7ED),
  icon: Icons.assignment_rounded,
  particles: [
    _P(Icons.assignment_rounded, 0.10, 17, 0.0),
    _P(Icons.edit_rounded, 0.82, 15, 0.14),
    _P(Icons.quiz_rounded, 0.25, 16, 0.30),
    _P(Icons.grade_rounded, 0.68, 14, 0.46),
    _P(Icons.fact_check_rounded, 0.50, 15, 0.60),
    _P(Icons.description_rounded, 0.88, 13, 0.75),
    _P(Icons.timer_rounded, 0.38, 14, 0.88),
  ],
);

const _fees = _MTheme(
  primary: Color(0xFF14B8A6),
  secondary: Color(0xFF2DD4BF),
  gradient: [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF0EA5E9)],
  bg: Color(0xFFF0FDFA),
  icon: Icons.payments_rounded,
  particles: [
    _P(Icons.payments_rounded, 0.08, 17, 0.0),
    _P(Icons.receipt_long_rounded, 0.85, 15, 0.16),
    _P(Icons.account_balance_wallet_rounded, 0.22, 16, 0.32),
    _P(Icons.credit_card_rounded, 0.70, 14, 0.48),
    _P(Icons.savings_rounded, 0.45, 15, 0.62),
    _P(Icons.currency_rupee_rounded, 0.90, 13, 0.78),
    _P(Icons.receipt_rounded, 0.33, 14, 0.90),
  ],
);

const _hr = _MTheme(
  primary: Color(0xFF0EA5E9),
  secondary: Color(0xFF38BDF8),
  gradient: [Color(0xFF0EA5E9), Color(0xFF0284C7), Color(0xFF6366F1)],
  bg: Color(0xFFF0F9FF),
  icon: Icons.people_alt_rounded,
  particles: [
    _P(Icons.people_rounded, 0.10, 17, 0.0),
    _P(Icons.badge_rounded, 0.80, 15, 0.15),
    _P(Icons.work_rounded, 0.25, 16, 0.30),
    _P(Icons.event_available_rounded, 0.68, 14, 0.46),
    _P(Icons.schedule_rounded, 0.48, 15, 0.62),
    _P(Icons.groups_rounded, 0.88, 13, 0.78),
    _P(Icons.account_balance_wallet_rounded, 0.35, 14, 0.90),
  ],
);

const _accounts = _MTheme(
  primary: Color(0xFF10B981),
  secondary: Color(0xFF34D399),
  gradient: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF0D9488)],
  bg: Color(0xFFF0FDF4),
  icon: Icons.account_balance_rounded,
  particles: [
    _P(Icons.account_balance_rounded, 0.08, 17, 0.0),
    _P(Icons.receipt_rounded, 0.82, 15, 0.18),
    _P(Icons.trending_up_rounded, 0.20, 16, 0.34),
    _P(Icons.pie_chart_rounded, 0.72, 14, 0.50),
    _P(Icons.swap_horiz_rounded, 0.48, 15, 0.65),
    _P(Icons.savings_rounded, 0.90, 13, 0.80),
    _P(Icons.bar_chart_rounded, 0.35, 14, 0.92),
  ],
);

const _behaviour = _MTheme(
  primary: Color(0xFFF59E0B),
  secondary: Color(0xFFFBBF24),
  gradient: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFEA580C)],
  bg: Color(0xFFFFFBEB),
  icon: Icons.psychology_rounded,
  particles: [
    _P(Icons.psychology_rounded, 0.10, 17, 0.0),
    _P(Icons.emoji_events_rounded, 0.82, 15, 0.16),
    _P(Icons.star_rounded, 0.22, 16, 0.32),
    _P(Icons.mood_rounded, 0.70, 14, 0.48),
    _P(Icons.sentiment_satisfied_rounded, 0.48, 15, 0.64),
    _P(Icons.leaderboard_rounded, 0.88, 13, 0.80),
    _P(Icons.school_rounded, 0.35, 14, 0.92),
  ],
);

const _admin = _MTheme(
  primary: Color(0xFFA855F7),
  secondary: Color(0xFFC084FC),
  gradient: [Color(0xFFA855F7), Color(0xFF9333EA), Color(0xFF7C3AED)],
  bg: Color(0xFFFDF4FF),
  icon: Icons.admin_panel_settings_rounded,
  particles: [
    _P(Icons.admin_panel_settings_rounded, 0.08, 17, 0.0),
    _P(Icons.badge_rounded, 0.85, 15, 0.15),
    _P(Icons.phone_rounded, 0.22, 16, 0.30),
    _P(Icons.mail_rounded, 0.70, 14, 0.46),
    _P(Icons.feedback_rounded, 0.48, 15, 0.62),
    _P(Icons.print_rounded, 0.90, 13, 0.78),
    _P(Icons.verified_rounded, 0.35, 14, 0.90),
  ],
);

const _role = _MTheme(
  primary: Color(0xFF6D28D9),
  secondary: Color(0xFF8B5CF6),
  gradient: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFF6366F1)],
  bg: Color(0xFFF5F3FF),
  icon: Icons.shield_rounded,
  particles: [
    _P(Icons.shield_rounded, 0.10, 17, 0.0),
    _P(Icons.lock_rounded, 0.80, 15, 0.18),
    _P(Icons.security_rounded, 0.25, 16, 0.35),
    _P(Icons.vpn_key_rounded, 0.68, 14, 0.50),
    _P(Icons.verified_user_rounded, 0.48, 15, 0.66),
    _P(Icons.admin_panel_settings_rounded, 0.88, 13, 0.82),
    _P(Icons.policy_rounded, 0.35, 14, 0.92),
  ],
);

const _library = _MTheme(
  primary: Color(0xFF3B82F6),
  secondary: Color(0xFF60A5FA),
  gradient: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF6366F1)],
  bg: Color(0xFFF0F9FF),
  icon: Icons.local_library_rounded,
  particles: [
    _P(Icons.local_library_rounded, 0.08, 17, 0.0),
    _P(Icons.menu_book_rounded, 0.85, 15, 0.16),
    _P(Icons.bookmark_rounded, 0.22, 16, 0.32),
    _P(Icons.auto_stories_rounded, 0.70, 14, 0.48),
    _P(Icons.collections_bookmark_rounded, 0.48, 15, 0.64),
    _P(Icons.category_rounded, 0.90, 13, 0.80),
    _P(Icons.library_books_rounded, 0.35, 14, 0.92),
  ],
);

const _transport = _MTheme(
  primary: Color(0xFFEA580C),
  secondary: Color(0xFFFB923C),
  gradient: [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFFDC2626)],
  bg: Color(0xFFFFF7ED),
  icon: Icons.directions_bus_rounded,
  particles: [
    _P(Icons.directions_bus_rounded, 0.10, 17, 0.0),
    _P(Icons.route_rounded, 0.82, 15, 0.16),
    _P(Icons.local_shipping_rounded, 0.25, 16, 0.32),
    _P(Icons.navigation_rounded, 0.68, 14, 0.48),
    _P(Icons.speed_rounded, 0.48, 15, 0.64),
    _P(Icons.commute_rounded, 0.88, 13, 0.80),
    _P(Icons.map_rounded, 0.35, 14, 0.92),
  ],
);

const _inventory = _MTheme(
  primary: Color(0xFF84CC16),
  secondary: Color(0xFFA3E635),
  gradient: [Color(0xFF84CC16), Color(0xFF65A30D), Color(0xFF16A34A)],
  bg: Color(0xFFF7FEE7),
  icon: Icons.inventory_2_rounded,
  particles: [
    _P(Icons.inventory_2_rounded, 0.08, 17, 0.0),
    _P(Icons.store_rounded, 0.85, 15, 0.16),
    _P(Icons.local_shipping_rounded, 0.22, 16, 0.32),
    _P(Icons.category_rounded, 0.70, 14, 0.48),
    _P(Icons.shopping_cart_rounded, 0.48, 15, 0.64),
    _P(Icons.warehouse_rounded, 0.90, 13, 0.80),
    _P(Icons.inventory_rounded, 0.35, 14, 0.92),
  ],
);

const _fallback = _MTheme(
  primary: Color(0xFF6366F1),
  secondary: Color(0xFF818CF8),
  gradient: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF7C3AED)],
  bg: Color(0xFFF8FAFF),
  icon: Icons.dashboard_rounded,
  particles: [
    _P(Icons.school_rounded, 0.1, 16, 0.0),
    _P(Icons.menu_book_rounded, 0.85, 14, 0.2),
    _P(Icons.calculate_rounded, 0.3, 15, 0.4),
    _P(Icons.science_rounded, 0.7, 14, 0.6),
    _P(Icons.brush_rounded, 0.5, 13, 0.8),
  ],
);

// ═══════════════════════════════════════════════════════════════════════════════
// APP SCAFFOLD
// ═══════════════════════════════════════════════════════════════════════════════

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  late final _MTheme _mt;

  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Floating particles
  late final AnimationController _particleCtrl;

  // School scene (bus, children)
  late final AnimationController _sceneCtrl;

  // Header icon glow
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _mt = _MTheme.from(widget.title);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _sceneCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _particleCtrl.dispose();
    _sceneCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await StorageService.to.clearAuthTokens();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.offAllNamed(AppRoutes.dashboard);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _mt.bg,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              // ── Decorative background circles ──
              Positioned(
                right: -60,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _mt.primary.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: 80,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _mt.secondary.withValues(alpha: 0.04),
                  ),
                ),
              ),
              // ── Floating module particles ──
              Positioned.fill(
                child: IgnorePointer(
                  child: _ModuleParticles(
                    controller: _particleCtrl,
                    theme: _mt,
                  ),
                ),
              ),
              // ── School scene (bus, children, buildings) ──
              Positioned.fill(
                child: IgnorePointer(
                  child: _SchoolScene(
                    controller: _sceneCtrl,
                    color: _mt.primary,
                  ),
                ),
              ),
              // ── Content with entrance animation ──
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: widget.body,
                ),
              ),
            ],
          ),
          floatingActionButton: widget.floatingActionButton,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _mt.gradient,
          ),
        ),
        // Decorative circles inside AppBar
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -15,
              bottom: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Get.offAllNamed(AppRoutes.dashboard),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated module icon with glow
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.12 + _glowAnim.value * 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.2 + _glowAnim.value * 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white
                        .withValues(alpha: 0.1 + _glowAnim.value * 0.15),
                    blurRadius: 8 + _glowAnim.value * 6,
                  ),
                ],
              ),
              child: Icon(_mt.icon, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            onTap: _logout,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      // Gradient divider line at bottom
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _mt.primary.withValues(alpha: 0.0),
                _mt.secondary.withValues(alpha: 0.5),
                _mt.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOATING MODULE PARTICLES
// ═══════════════════════════════════════════════════════════════════════════════

class _ModuleParticles extends StatelessWidget {
  final AnimationController controller;
  final _MTheme theme;

  const _ModuleParticles({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          children: theme.particles.map((p) {
            final t = (controller.value + p.phase) % 1.0;
            // Float upward
            final y = h * (1.0 - t * 0.85);
            // Gentle horizontal sway
            final xSway =
                10 * _sin((controller.value + p.phase) * 6.283);
            final opacity = t < 0.12
                ? t / 0.12
                : t > 0.78
                    ? (1.0 - t) / 0.22
                    : 1.0;
            return Positioned(
              left: p.x * w + xSway,
              top: y,
              child: Opacity(
                opacity: (opacity * 0.14).clamp(0.0, 1.0),
                child: Icon(p.icon, color: theme.primary, size: p.sz),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static double _sin(double x) {
    x = x % 6.283;
    if (x > 3.1416) x -= 6.283;
    final x2 = x * x;
    return x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCHOOL SCENE — big visible bus, playing children, classroom, trees
// ═══════════════════════════════════════════════════════════════════════════════

class _SchoolScene extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  const _SchoolScene({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        // Bus drives across the bottom
        final busX = (t * (w + 120)) - 60;
        // Second bus (smaller, upper lane, opposite direction)
        final bus2X = w - (((t * 0.7 + 0.5) % 1.0) * (w + 100)) + 50;
        // Children bouncing
        final bob = _ModuleParticles._sin;
        final b1 = 6.0 * bob(t * 12.566);
        final b2 = 5.0 * bob((t + 0.25) * 12.566);
        final b3 = 7.0 * bob((t + 0.5) * 12.566);
        final b4 = 4.0 * bob((t + 0.75) * 12.566);
        // Ball bouncing high
        final ballY = 18.0 * (bob(t * 18.85)).abs();
        // Bird flying
        final birdX = ((t * 1.4) % 1.0) * (w + 40) - 20;
        final birdY = h * 0.08 + 8.0 * bob(t * 9.42);

        return Stack(
          children: [
            // ── Ground strip with grass feel ──
            Positioned(
              left: 0, right: 0, bottom: 0, height: 36,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.0),
                      color.withValues(alpha: 0.06),
                      color.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),

            // ── Road line ──
            Positioned(
              left: 0, right: 0, bottom: 18,
              child: Container(
                height: 1.5,
                color: color.withValues(alpha: 0.08),
              ),
            ),

            // ── School building (left) ──
            Positioned(
              left: 8, bottom: 20,
              child: Icon(Icons.school_rounded,
                  size: 44, color: color.withValues(alpha: 0.10)),
            ),

            // ── Trees ──
            Positioned(
              right: 12, bottom: 20,
              child: Icon(Icons.park_rounded,
                  size: 38, color: color.withValues(alpha: 0.08)),
            ),
            Positioned(
              left: w * 0.38, bottom: 20,
              child: Icon(Icons.nature_rounded,
                  size: 30, color: color.withValues(alpha: 0.06)),
            ),
            Positioned(
              right: w * 0.3, bottom: 22,
              child: Icon(Icons.forest_rounded,
                  size: 32, color: color.withValues(alpha: 0.05)),
            ),

            // ── Main bus (big, moving right) ──
            Positioned(
              left: busX, bottom: 20,
              child: Icon(Icons.directions_bus_rounded,
                  size: 36, color: color.withValues(alpha: 0.14)),
            ),

            // ── Second bus (smaller, upper lane, moving left) ──
            Positioned(
              left: bus2X, bottom: 28,
              child: Icon(Icons.airport_shuttle_rounded,
                  size: 24, color: color.withValues(alpha: 0.08)),
            ),

            // ── Playing children (big, bouncing) ──
            Positioned(
              left: w * 0.15, bottom: 36 + b1,
              child: Icon(Icons.directions_run_rounded,
                  size: 28, color: color.withValues(alpha: 0.12)),
            ),
            Positioned(
              left: w * 0.32, bottom: 36 + b2,
              child: Icon(Icons.directions_walk_rounded,
                  size: 26, color: color.withValues(alpha: 0.10)),
            ),
            Positioned(
              left: w * 0.62, bottom: 38 + b3,
              child: Icon(Icons.boy_rounded,
                  size: 28, color: color.withValues(alpha: 0.11)),
            ),
            Positioned(
              left: w * 0.82, bottom: 36 + b4,
              child: Icon(Icons.girl_rounded,
                  size: 26, color: color.withValues(alpha: 0.09)),
            ),

            // ── Bouncing ball ──
            Positioned(
              left: w * 0.48, bottom: 38 + ballY,
              child: Icon(Icons.sports_soccer_rounded,
                  size: 16, color: color.withValues(alpha: 0.12)),
            ),

            // ── Teacher (classroom area, top-right) ──
            Positioned(
              right: 16, top: h * 0.18,
              child: Icon(Icons.cast_for_education_rounded,
                  size: 30, color: color.withValues(alpha: 0.06)),
            ),

            // ── Book stack (mid-left) ──
            Positioned(
              left: 12, top: h * 0.40,
              child: Icon(Icons.auto_stories_rounded,
                  size: 26, color: color.withValues(alpha: 0.05)),
            ),

            // ── Flying birds ──
            Positioned(
              left: birdX, top: birdY,
              child: Icon(Icons.flutter_dash,
                  size: 20, color: color.withValues(alpha: 0.07)),
            ),
            Positioned(
              left: birdX - 30, top: birdY + 12,
              child: Icon(Icons.flutter_dash,
                  size: 14, color: color.withValues(alpha: 0.05)),
            ),
          ],
        );
      },
    );
  }
}

