import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // Logo entrance
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Title slide-up
  late final AnimationController _titleCtrl;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;

  // Ring pulse
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringFade;

  // Particles
  late final AnimationController _particleCtrl;

  // Tagline
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();

    // Logo: scale from 0.3→1.0 + fade in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );

    // Title: slide up + fade
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

    // Ring pulse that expands outward
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringScale = Tween<double>(begin: 0.8, end: 2.5).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringFade = Tween<double>(begin: 0.4, end: 0.0).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));

    // Particles (continuous)
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Tagline fade
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn);

    // Sequence animations
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _tagCtrl.forward();

    // Navigate after splash
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final loggedIn = await StorageService.to.isLoggedIn();
    Get.offAllNamed(loggedIn ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _ringCtrl.dispose();
    _particleCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
                Color(0xFF6D28D9),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Decorative background circles ──
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -70,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.15,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),

              // ── Floating school particles ──
              Positioned.fill(
                child: IgnorePointer(
                  child: _SplashParticles(controller: _particleCtrl),
                ),
              ),

              // ── Ring pulse ──
              AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Container(
                  width: 120 * _ringScale.value,
                  height: 120 * _ringScale.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: _ringFade.value),
                      width: 2,
                    ),
                  ),
                ),
              ),

              // ── Center content ──
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/eSkoolia_logo.jpeg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Text(
                        'eSkoolia',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      'Smart School Management',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading dots
                  FadeTransition(
                    opacity: _tagFade,
                    child: const _LoadingDots(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Splash Particles ──────────────────────────────────────────────────────────

class _SplashParticles extends StatelessWidget {
  final AnimationController controller;
  const _SplashParticles({required this.controller});

  static const _icons = [
    (Icons.school_rounded, 0.08, 22.0, 0.0),
    (Icons.menu_book_rounded, 0.88, 18.0, 0.12),
    (Icons.calculate_rounded, 0.20, 16.0, 0.25),
    (Icons.science_rounded, 0.72, 20.0, 0.38),
    (Icons.brush_rounded, 0.48, 15.0, 0.50),
    (Icons.music_note_rounded, 0.35, 17.0, 0.62),
    (Icons.sports_soccer_rounded, 0.60, 14.0, 0.74),
    (Icons.computer_rounded, 0.90, 16.0, 0.86),
    (Icons.auto_stories_rounded, 0.15, 18.0, 0.42),
    (Icons.emoji_events_rounded, 0.78, 15.0, 0.55),
  ];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Stack(
        children: _icons.map((p) {
          final (icon, xFrac, sz, phase) = p;
          final t = (controller.value + phase) % 1.0;
          final y = h * (1.0 - t * 0.9);
          final opacity = t < 0.1
              ? t / 0.1
              : t > 0.8
                  ? (1.0 - t) / 0.2
                  : 1.0;
          return Positioned(
            left: xFrac * w,
            top: y,
            child: Opacity(
              opacity: (opacity * 0.12).clamp(0.0, 1.0),
              child: Icon(icon, color: Colors.white, size: sz),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Loading Dots ──────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final t = (_ctrl.value - delay).clamp(0.0, 1.0);
          final scale = t < 0.5 ? 0.6 + t * 0.8 : 1.0 - (t - 0.5) * 0.8;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8 * scale,
            height: 8 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.5 + scale * 0.3),
            ),
          );
        }),
      ),
    );
  }
}
