import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour palette ─────────────────────────────────────────────────────────────
const kFinPrimary = Color(0xFF0D9488); // teal-600
const kFinRed = Color(0xFFDC2626);
const kFinGreen = Color(0xFF059669);
const kFinAmber = Color(0xFFD97706);
const kFinBlue = Color(0xFF2563EB);
const kFinPurple = Color(0xFF7C3AED);
const kFinGray = Color(0xFF6B7280);
const kFinDebit = Color(0xFFDC2626);
const kFinCredit = Color(0xFF059669);

// ── Account type colours ────────────────────────────────────────────────────────
Color finTypeColor(String type) {
  switch (type) {
    case 'asset':
      return kFinBlue;
    case 'liability':
      return kFinRed;
    case 'equity':
      return kFinPurple;
    case 'income':
      return kFinGreen;
    case 'expense':
      return kFinAmber;
    default:
      return kFinGray;
  }
}

String finTypeLabel(String type) {
  switch (type) {
    case 'asset':
      return 'Asset';
    case 'liability':
      return 'Liability';
    case 'equity':
      return 'Equity';
    case 'income':
      return 'Income';
    case 'expense':
      return 'Expense';
    default:
      return type;
  }
}

// ── Amount formatter ───────────────────────────────────────────────────────────
String finFmtAmt(String s) {
  final v = double.tryParse(s) ?? 0.0;
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

// ── Date formatter ─────────────────────────────────────────────────────────────
String finFmtDate(String iso) {
  if (iso.isEmpty) return '–';
  try {
    final dt = DateTime.parse(iso);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return iso;
  }
}

// ── Card decoration ────────────────────────────────────────────────────────────
BoxDecoration finCardDecoration({Color? accent}) => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFE8FBF0)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kFinPrimary.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: kFinPrimary.withValues(alpha: 0.10),
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
Widget finLabel(String text) => Padding(
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
Widget finTextField(
  TextEditingController ctrl,
  String hint, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  String? prefixText,
}) =>
    TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kFinPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kFinPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kFinPrimary, width: 1.8),
        ),
      ),
    );

// ── Dropdown ──────────────────────────────────────────────────────────────────
Widget finDropdown<T>({
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
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kFinPrimary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kFinPrimary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kFinPrimary, width: 1.8),
        ),
      ),
    );

// ── Primary button ────────────────────────────────────────────────────────────
Widget finPrimaryBtn({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  Color color = kFinPrimary,
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

// ── Date picker tile ──────────────────────────────────────────────────────────
Widget finDateTile({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
}) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(color: kFinPrimary.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                    : label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: date != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );

// ── Active badge ───────────────────────────────────────────────────────────────
Widget finActiveBadge(bool active) {
  final color = active ? kFinGreen : kFinGray;
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

// ── Type badge ─────────────────────────────────────────────────────────────────
Widget finTypeBadge(String type) {
  final color = finTypeColor(type);
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
      finTypeLabel(type),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Entry type badge ───────────────────────────────────────────────────────────
Widget finEntryBadge(String type) {
  final isDebit = type == 'debit';
  final color = isDebit ? kFinDebit : kFinCredit;
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
      isDebit ? 'Debit' : 'Credit',
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Amount badge ───────────────────────────────────────────────────────────────
Widget finAmtBadge(String amount, {bool isDebit = true}) {
  final color = isDebit ? kFinDebit : kFinCredit;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      '${isDebit ? '-' : '+'}${finFmtAmt(amount)}',
      style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

// ── Summary stat card ─────────────────────────────────────────────────────────
Widget finStatCard({
  required String label,
  required String value,
  required Color color,
  required IconData icon,
}) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: color),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

// ── Info chip ──────────────────────────────────────────────────────────────────
Widget finChip(IconData icon, String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

// ── Action button ──────────────────────────────────────────────────────────────
Widget finActionBtn(IconData icon, Color color, VoidCallback onTap) =>
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
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );

// ── Empty state ────────────────────────────────────────────────────────────────
Widget finEmptyState(String msg,
        {IconData icon = Icons.inbox_outlined}) =>
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
                  kFinPrimary.withValues(alpha: 0.15),
                  kFinPrimary.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: kFinPrimary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 52, color: kFinPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull down to refresh',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 12, color: const Color(0xFFD1D5DB)),
          ),
        ],
      ),
    );

// ── Delete dialog ─────────────────────────────────────────────────────────────
void finDeleteDialog(
    BuildContext ctx, String msg, VoidCallback onConfirm) {
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: Text(msg, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: GoogleFonts.inter()),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kFinRed, kFinRed.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kFinRed.withValues(alpha: 0.35),
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
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ),
      ],
    ),
  );
}

// ── Sheet drag handle ─────────────────────────────────────────────────────────
Widget finSheetHandle() => Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
