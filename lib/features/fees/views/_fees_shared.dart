import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colours ────────────────────────────────────────────────────────────────────
const kFeesPrimary = Color(0xFF4F46E5);
const kFeesTeal = Color(0xFF0F766E);
const kFeesAmber = Color(0xFFD97706);
const kFeesRed = Color(0xFFDC2626);
const kFeesGreen = Color(0xFF16A34A);
const kFeesBg = Color(0xFFF9FBFF);

// ── Amount formatter ───────────────────────────────────────────────────────────
String fmtAmt(double v) {
  if (v == 0) return '0.00';
  final abs = v.abs();
  final parts = abs.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];
  final buf = StringBuffer();
  final len = intPart.length;
  for (var i = 0; i < len; i++) {
    if (i != 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${v < 0 ? '-' : ''}$buf.$decPart';
}

// ── Card decoration ────────────────────────────────────────────────────────────
BoxDecoration fCardDecoration() => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFE8FAF6)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.10),
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
Widget fLabel(String text) => Padding(
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
Widget fTextField(
  TextEditingController ctrl,
  String hint, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? prefixText,
  bool readOnly = false,
  VoidCallback? onTap,
}) =>
    TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF9CA3AF)),
        prefixText: prefixText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: kFeesPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: kFeesPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: kFeesPrimary, width: 1.8),
        ),
      ),
    );

// ── Dropdown ───────────────────────────────────────────────────────────────────
Widget fDropdown<T>({
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
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: kFeesPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: kFeesPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: kFeesPrimary, width: 1.8),
        ),
      ),
    );

// ── Primary button ─────────────────────────────────────────────────────────────
Widget fPrimaryBtn({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  Color color = kFeesPrimary,
}) =>
    SizedBox(
      width: double.infinity,
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );

// ── Status badge ───────────────────────────────────────────────────────────────
Widget fStatusBadge(String status) {
  Color color;
  String label;

  switch (status.toLowerCase()) {
    case 'paid':
      color = const Color(0xFF166534);
      label = 'Paid';
      break;
    case 'partial':
      color = const Color(0xFF92400E);
      label = 'Partial';
      break;
    default:
      color = const Color(0xFF991B1B);
      label = 'Unpaid';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    child: Text(
      label,
      style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

// ── Active/Inactive badge ──────────────────────────────────────────────────────
Widget fActiveBadge(bool active) {
  final color = active
      ? const Color(0xFF166534)
      : const Color(0xFF6B7280);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    child: Text(
      active ? 'Active' : 'Inactive',
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Method badge ───────────────────────────────────────────────────────────────
Widget fMethodBadge(String method) {
  const colors = {
    'cash': Color(0xFF0F766E),
    'bank': Color(0xFF1D4ED8),
    'online': Color(0xFF7C3AED),
    'wallet': Color(0xFFD97706),
    'cheque': Color(0xFF374151),
  };
  final color = colors[method.toLowerCase()] ?? const Color(0xFF374151);
  return Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    child: Text(
      method[0].toUpperCase() + method.substring(1),
      style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

// ── Summary card ───────────────────────────────────────────────────────────────
Widget fSummaryCard({
  required String label,
  required String value,
  required Color accent,
  required IconData icon,
}) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: accent.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );

// ── Empty state ────────────────────────────────────────────────────────────────
Widget fEmptyState(String msg, {IconData icon = Icons.inbox_outlined}) =>
    Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF14B8A6).withValues(alpha: 0.14),
                    const Color(0xFF14B8A6).withValues(alpha: 0.04),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 48, color: const Color(0xFFB0B8C8)),
            ),
            const SizedBox(height: 14),
            Text(msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280))),
            const SizedBox(height: 6),
            Text('Pull down to refresh',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFFB0B8C8))),
          ],
        ),
      ),
    );

// ── Delete confirmation dialog ─────────────────────────────────────────────────
Future<void> fDeleteDialog(
  BuildContext context,
  String message,
  VoidCallback onConfirm,
) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Confirm Delete',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kFeesRed,
                  kFeesRed.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: kFeesRed.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Delete', style: GoogleFonts.inter()),
            ),
          ),
        ],
      ),
    );

// ── Action icon button ─────────────────────────────────────────────────────────
Widget fActionBtn(
  IconData icon,
  Color color,
  VoidCallback onTap,
) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );

// ── Filter bar ─────────────────────────────────────────────────────────────────
Widget fFilterContainer({required Widget child}) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: fCardDecoration(),
      child: child,
    );
