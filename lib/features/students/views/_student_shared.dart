// Shared micro-widgets used across all student views — dashboard-themed design.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Theme Colours ──────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF6366F1);
const _kAccent = Color(0xFF4F46E5);
const _kViolet = Color(0xFF7C3AED);

// ── Card Decoration ─────────────────────────────────────────────────────────
// Matches dashboard module-card aesthetic: pastel gradient, tinted shadow, round.

final sCardDecoration = BoxDecoration(
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF0EEFF)],
  ),
  border: Border.all(color: _kPrimary.withValues(alpha: 0.12)),
  borderRadius: BorderRadius.circular(18),
  boxShadow: [
    BoxShadow(
        color: _kPrimary.withValues(alpha: 0.10),
        blurRadius: 16,
        offset: const Offset(0, 6)),
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 1)),
  ],
);

// ── Typography ───────────────────────────────────────────────────────────────

Widget sectionHeader(String text) => Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kPrimary, _kViolet],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827)),
        ),
      ],
    );

Widget sFieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: _kPrimary.withValues(alpha: 0.6)),
      ),
    );

// ── Text Field ───────────────────────────────────────────────────────────────
// Glassmorphic-style input with colored focus glow.

Widget sTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType? keyboardType,
  bool readOnly = false,
  VoidCallback? onTap,
  Widget? suffixIcon,
  ValueChanged<String>? onChanged,
}) =>
    TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.15))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 1.8)),
      ),
    );

// ── Dropdown ─────────────────────────────────────────────────────────────────

Widget sDropdown<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint,
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF9CA3AF))),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        style:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
        iconSize: 20,
        dropdownColor: Colors.white,
      ),
    );

// ── Search Bar ───────────────────────────────────────────────────────────────

Widget sSearchBar({
  required String hint,
  required ValueChanged<String> onChanged,
}) =>
    Container(
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
        style:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
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
    );

// ── Buttons ──────────────────────────────────────────────────────────────────

Widget sIconBtn(IconData icon, Color color, VoidCallback onPressed) =>
    Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );

Widget sRefreshButton(VoidCallback onTap) => Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kPrimary, _kViolet]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
        onPressed: onTap,
        tooltip: 'Refresh',
      ),
    );

// ── Empty State ──────────────────────────────────────────────────────────────

Widget sEmptyState(String message, IconData icon) => Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Gradient circle with animated feel
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPrimary.withValues(alpha: 0.12),
                  _kViolet.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon,
                size: 40, color: _kPrimary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Pull down to refresh',
              style: GoogleFonts.inter(
                  color: const Color(0xFFD1D5DB), fontSize: 12)),
        ]),
      ),
    );

// ── Delete Dialog ─────────────────────────────────────────────────────────────

Widget sDeleteDialog({
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) =>
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFDC2626).withValues(alpha: 0.15),
                const Color(0xFFDC2626).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFDC2626), size: 22),
        ),
        const SizedBox(width: 12),
        Text('Confirm Delete',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Text(message,
          style: GoogleFonts.inter(
              color: const Color(0xFF6B7280), height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );

// ── Confirm Dialog ────────────────────────────────────────────────────────────

Widget sConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required Color confirmColor,
  required VoidCallback onConfirm,
}) =>
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(title,
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
      content: Text(message,
          style: GoogleFonts.inter(
              color: const Color(0xFF6B7280), height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [confirmColor, confirmColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: confirmColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text(confirmLabel,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );

// ── Badge Chip ────────────────────────────────────────────────────────────────

Widget sBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );

// ── Section Divider ───────────────────────────────────────────────────────────

Widget sSectionDivider(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kPrimary, _kViolet],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kPrimary,
                letterSpacing: 0.3),
          ),
        ],
      ),
    );

// ── Loading Indicator ─────────────────────────────────────────────────────────

Widget sSavingIndicator() => const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
