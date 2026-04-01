import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPrimary = Color(0xFF6366F1);
const _kViolet = Color(0xFF7C3AED);

/// Reusable search bar matching the dashboard glass-morphic style.
class AdminSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const AdminSearchBar(
      {super.key, this.hint = 'Search...', required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kPrimary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          style: GoogleFonts.inter(
              fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_kPrimary, _kViolet],
              ).createShader(bounds),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 22),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: false,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
