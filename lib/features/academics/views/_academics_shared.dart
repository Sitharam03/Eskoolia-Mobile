import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colours ──────────────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kBorder = Color(0xFFE0E4EF);
const _kGrey = Color(0xFF6B7280);
const _kRed = Color(0xFFDC2626);
const _kViolet = Color(0xFF7C3AED);

// ── Card decoration ──────────────────────────────────────────────────────────

/// White-to-soft-violet gradient card with dramatic indigo + black shadows.
/// Never put color+decoration together — decoration already carries the fill.
BoxDecoration aCardDecoration() => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFF0EEFF)],
      ),
      border: Border.all(color: _kIndigo.withValues(alpha: 0.12)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: _kIndigo.withValues(alpha: 0.10),
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

// ── Text field ───────────────────────────────────────────────────────────────

TextFormField aTextField(
  TextEditingController controller,
  String label, {
  String? hint,
  TextInputType? keyboardType,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: _kGrey),
      hintStyle:
          GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kIndigo, width: 1.8),
      ),
    ),
  );
}

// ── Dropdown ─────────────────────────────────────────────────────────────────

DropdownButtonFormField<T> aDropdown<T>({
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required String label,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    items: items,
    onChanged: onChanged,
    isExpanded: true,
    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: _kGrey),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kIndigo, width: 1.8),
      ),
    ),
  );
}

// ── Search bar ───────────────────────────────────────────────────────────────

Widget aSearchBar(
  TextEditingController controller,
  String hint, {
  ValueChanged<String>? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kIndigo.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: _kIndigo.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_kIndigo, _kViolet],
          ).createShader(bounds),
          child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
        ),
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────

Widget aEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kIndigo, _kViolet],
            ),
            boxShadow: [
              BoxShadow(
                color: _kIndigo.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.inbox_rounded, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pull down to refresh',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12, color: _kGrey),
        ),
      ],
    ),
  );
}

// ── Dialogs ──────────────────────────────────────────────────────────────────

Future<bool> aDeleteDialog(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel', style: GoogleFonts.inter(color: _kGrey)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kRed.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> aConfirmDialog(
    BuildContext context, String title, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel', style: GoogleFonts.inter(color: _kGrey)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kIndigo, Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kIndigo.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm', style: GoogleFonts.inter()),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ── Progress indicator ────────────────────────────────────────────────────────

Widget aSavingIndicator() {
  return const LinearProgressIndicator(
    color: _kIndigo,
    backgroundColor: Color(0xFFE0E7FF),
  );
}

// ── Badge ─────────────────────────────────────────────────────────────────────

Widget aBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Section header ────────────────────────────────────────────────────────────

Widget aSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kIndigo, _kViolet],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    ),
  );
}

// ── Field label ───────────────────────────────────────────────────────────────

Widget aFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _kGrey,
      ),
    ),
  );
}

// ── Icon button ───────────────────────────────────────────────────────────────

Widget aIconBtn(IconData icon, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}

// ── Buttons ───────────────────────────────────────────────────────────────────

Widget aPrimaryBtn(
  String label,
  VoidCallback? onPressed, {
  bool isLoading = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kIndigo, Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _kIndigo.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    ),
  );
}

Widget aSecondaryBtn(String label, VoidCallback? onPressed) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _kGrey,
        side: const BorderSide(color: _kBorder),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

Widget aDangerBtn(String label, VoidCallback? onPressed) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kRed, Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _kRed.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          label,
          style:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

// ── Info card ─────────────────────────────────────────────────────────────────

Widget aInfoCard({
  required String title,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
    decoration: aCardDecoration(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _kIndigo.withValues(alpha: 0.15),
                _kViolet.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description_rounded, size: 18, color: _kIndigo),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kGrey,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(height: 6),
                trailing,
              ],
            ],
          ),
        ),
        if (onEdit != null || onDelete != null) ...[
          const SizedBox(width: 8),
          Column(
            children: [
              if (onEdit != null)
                aIconBtn(
                    Icons.edit_rounded, const Color(0xFF4F46E5), onEdit),
              if (onDelete != null)
                aIconBtn(Icons.delete_rounded, _kRed, onDelete),
            ],
          ),
        ],
      ],
    ),
  );
}
