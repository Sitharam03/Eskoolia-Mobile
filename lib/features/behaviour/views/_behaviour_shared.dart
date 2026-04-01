import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour palette ─────────────────────────────────────────────────────────────
const kBehPrimary = Color(0xFF7C3AED); // violet
const kBehRed = Color(0xFFDC2626);
const kBehGreen = Color(0xFF16A34A);
const kBehAmber = Color(0xFFD97706);
const kBehBlue = Color(0xFF2563EB);
const kBehGray = Color(0xFF6B7280);
const kBehBg = Color(0xFFF9F5FF);

// ── Card decoration ────────────────────────────────────────────────────────────
BoxDecoration bCardDecoration({Color? borderColor}) => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFFFF8E1)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
          color: borderColor ?? const Color(0xFFF59E0B).withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: kBehPrimary.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );

// ── Section label ──────────────────────────────────────────────────────────────
Widget bLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: const Color(0xFF6B7280),
        ),
      ),
    );

// ── Text field ─────────────────────────────────────────────────────────────────
Widget bTextField(
  TextEditingController ctrl,
  String hint, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  String? prefixText,
}) =>
    TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: kBehPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: kBehPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBehPrimary, width: 1.8),
        ),
      ),
    );

// ── Dropdown ──────────────────────────────────────────────────────────────────
Widget bDropdown<T>({
  required String hint,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) =>
    DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: kBehPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: kBehPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBehPrimary, width: 1.8),
        ),
      ),
    );

// ── Primary button ────────────────────────────────────────────────────────────
Widget bPrimaryBtn({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  Color color = kBehPrimary,
  IconData? icon,
}) =>
    SizedBox(
      width: double.infinity,
      height: 46,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16),
                      const SizedBox(width: 6),
                    ],
                    Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );

// ── Point badge ───────────────────────────────────────────────────────────────
Widget bPointBadge(int point) {
  final isNeg = point < 0;
  final color = isNeg ? kBehRed : kBehGreen;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isNeg ? Icons.trending_down : Icons.trending_up,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          '${isNeg ? '' : '+'}$point pts',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

// ── Info chip ─────────────────────────────────────────────────────────────────
Widget bChip(IconData icon, String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ],
      ),
    );

// ── Empty state ───────────────────────────────────────────────────────────────
Widget bEmptyState(String msg, {IconData icon = Icons.inbox_outlined}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kBehPrimary.withValues(alpha: 0.15),
                  kBehPrimary.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: kBehPrimary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 52, color: const Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 14),
          Text(msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: const Color(0xFF9CA3AF))),
          const SizedBox(height: 6),
          Text('Pull down to refresh',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFFBDBDBD))),
        ],
      ),
    );

// ── Delete dialog ─────────────────────────────────────────────────────────────
void bDeleteDialog(BuildContext ctx, String msg, VoidCallback onConfirm) {
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: Text(msg, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter())),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kBehRed, kBehRed.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kBehRed.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ),
      ],
    ),
  );
}

// ── Action button ─────────────────────────────────────────────────────────────
Widget bActionBtn(IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );

// ── Filter section wrapper ────────────────────────────────────────────────────
Widget bFilterBox({required Widget child}) => Container(
      padding: const EdgeInsets.all(14),
      decoration: bCardDecoration(),
      child: child,
    );

// ── Section header ────────────────────────────────────────────────────────────
Widget bSectionHeader(String title, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  kBehPrimary,
                  kBehPrimary.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );

// ── Rank medal ────────────────────────────────────────────────────────────────
Widget bRankBadge(int rank) {
  Color color;
  IconData? icon;
  if (rank == 1) {
    color = const Color(0xFFF59E0B);
    icon = Icons.emoji_events;
  } else if (rank == 2) {
    color = const Color(0xFF9CA3AF);
    icon = Icons.emoji_events;
  } else if (rank == 3) {
    color = const Color(0xFFB45309);
    icon = Icons.emoji_events;
  } else {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kBehGray),
      ),
    );
  }
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: 18, color: color),
  );
}

// ── Date/time formatter ───────────────────────────────────────────────────────
String bFmtDate(String iso) {
  if (iso.isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$d/$m/$y';
  } catch (_) {
    return iso.split('T').first;
  }
}

String bFmtDateTime(String iso) {
  if (iso.isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$d/$m/$y  $h:$min $ap';
  } catch (_) {
    return iso;
  }
}
