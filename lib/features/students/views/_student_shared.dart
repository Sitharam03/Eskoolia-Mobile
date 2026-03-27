// Shared micro-widgets used across all student views.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Decoration ──────────────────────────────────────────────────────────────

final sCardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE5E7EB)),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2)),
  ],
);

// ── Typography ───────────────────────────────────────────────────────────────

Widget sectionHeader(String text) => Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827)),
    );

Widget sFieldLabel(String text) => Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: const Color(0xFF6B7280)),
    );

// ── Inputs ───────────────────────────────────────────────────────────────────

Widget sTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType? keyboardType,
  bool readOnly = false,
  VoidCallback? onTap,
  Widget? suffixIcon,
}) =>
    TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      ),
    );

Widget sDropdown<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF9CA3AF))),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        style:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
        iconSize: 20,
      ),
    );

// ── Search bar ───────────────────────────────────────────────────────────────

Widget sSearchBar({
  required String hint,
  required ValueChanged<String> onChanged,
}) =>
    TextField(
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        prefixIcon:
            const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      ),
    );

// ── Buttons ──────────────────────────────────────────────────────────────────

Widget sIconBtn(IconData icon, Color color, VoidCallback onPressed) =>
    IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );

Widget sRefreshButton(VoidCallback onTap) => IconButton(
      icon: const Icon(Icons.refresh_rounded,
          color: Color(0xFF4F46E5), size: 20),
      onPressed: onTap,
      tooltip: 'Refresh',
    );

// ── Empty state ───────────────────────────────────────────────────────────────

Widget sEmptyState(String message, IconData icon) => Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.grey.shade500, fontSize: 14)),
        ]),
      ),
    );

// ── Delete dialog ─────────────────────────────────────────────────────────────

Widget sDeleteDialog({
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) =>
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: Color(0xFFDC2626), size: 22),
        const SizedBox(width: 8),
        Text('Confirm Delete',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Text(message,
          style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text('Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );

// ── Confirm dialog (generic) ──────────────────────────────────────────────────

Widget sConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required Color confirmColor,
  required VoidCallback onConfirm,
}) =>
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
      content: Text(message,
          style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text(confirmLabel,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );

// ── Badge chip ────────────────────────────────────────────────────────────────

Widget sBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );

// ── Section divider ───────────────────────────────────────────────────────────

Widget sSectionDivider(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5),
      ),
    );

// ── Loading overlay ───────────────────────────────────────────────────────────

Widget sSavingIndicator() => const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
