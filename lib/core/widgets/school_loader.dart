import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A school-themed loading widget with animated bouncing school icons.
/// Use this instead of CircularProgressIndicator for page-level loading states.
class SchoolLoader extends StatefulWidget {
  final Color? color;
  final String? message;
  const SchoolLoader({super.key, this.color, this.message});

  @override
  State<SchoolLoader> createState() => _SchoolLoaderState();
}

class _SchoolLoaderState extends State<SchoolLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _icons = [
    Icons.menu_book_rounded,
    Icons.school_rounded,
    Icons.edit_rounded,
    Icons.science_rounded,
    Icons.calculate_rounded,
    Icons.brush_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? const Color(0xFF6366F1);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_icons.length, (i) {
                  final delay = i * 0.12;
                  final t = (_ctrl.value - delay).clamp(0.0, 1.0);
                  final bounce = t < 0.5 ? (t * 2) : 2.0 - (t * 2);
                  final scale = 0.6 + bounce * 0.5;
                  final yOff = -bounce * 16;
                  final opacity = 0.3 + bounce * 0.7;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.translate(
                      offset: Offset(0, yOff),
                      child: Opacity(
                        opacity: opacity.clamp(0.3, 1.0),
                        child: Container(
                          width: 36 * scale,
                          height: 36 * scale,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                c.withValues(alpha: 0.15 + bounce * 0.15),
                                c.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Icon(
                            _icons[i],
                            size: 18 * scale,
                            color: c.withValues(alpha: 0.4 + bounce * 0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.message ?? 'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
