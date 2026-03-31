import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '_student_nav_tabs.dart';

class StudentAttendanceView extends StatefulWidget {
  const StudentAttendanceView({super.key});

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  String? _selectedClass;
  String? _selectedSection;
  DateTime _date = DateTime.now();

  static const _classes = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  static const _sections = ['A', 'B', 'C'];

  static const _statusColors = {
    'P': Color(0xFF10B981),
    'A': Color(0xFFEF4444),
    'L': Color(0xFFF59E0B),
  };

  final _rows = <Map<String, String>>[
    {'roll': '01', 'name': 'Alice Johnson', 'status': 'P'},
    {'roll': '02', 'name': 'Bob Smith', 'status': 'P'},
    {'roll': '03', 'name': 'Carol White', 'status': 'A'},
    {'roll': '04', 'name': 'David Brown', 'status': 'P'},
    {'roll': '05', 'name': 'Eva Davis', 'status': 'L'},
    {'roll': '06', 'name': 'Frank Miller', 'status': 'P'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Attendance',
      body: Column(
        children: [
          const StudentNavTabs(activeRoute: AppRoutes.studentAttendance),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _filterCard(context),
                  const SizedBox(height: 14),
                  _attendanceTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.filter_list,
                    size: 16, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 10),
              Text('Filter Attendance',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827))),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: _dropdown('Class', _classes, _selectedClass,
                      (v) => setState(() => _selectedClass = v))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _dropdown(
                          'Section', _sections, _selectedSection,
                          (v) => setState(() => _selectedSection = v))),
                ]),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Text(
                        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded,
                          color: Color(0xFF9CA3AF)),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search_rounded, size: 16),
                    label: Text('Load Students',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String hint, List<String> options, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle:
            GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151)),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _attendanceTable() {
    final present = _rows.where((r) => r['status'] == 'P').length;
    final absent = _rows.where((r) => r['status'] == 'A').length;
    final leave = _rows.where((r) => r['status'] == 'L').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Stats row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              _statChip('Present', present, const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _statChip('Absent', absent, const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _statChip('Leave', leave, const Color(0xFFF59E0B)),
              const Spacer(),
              _legend('P', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _legend('A', const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _legend('L', const Color(0xFFF59E0B)),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            color: const Color(0xFFF3F4F6),
            child: Row(children: [
              SizedBox(
                  width: 36,
                  child: Text('Roll',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
              Expanded(
                  child: Text('Student Name',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
              SizedBox(
                  width: 111,
                  child: Text('Status',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
            ]),
          ),
          // Rows
          ..._rows.asMap().entries.map((e) {
            final row = e.value;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: e.key.isEven ? Colors.white : const Color(0xFFFAFAFA),
                border: e.key < _rows.length - 1
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF3F4F6)))
                    : null,
                borderRadius: e.key == _rows.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(13))
                    : null,
              ),
              child: Row(children: [
                SizedBox(
                  width: 36,
                  child: Text(row['roll']!,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280))),
                ),
                Expanded(
                  child: Text(row['name']!,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827))),
                ),
                SizedBox(
                  width: 111,
                  child: Row(children: ['P', 'A', 'L'].map((s) {
                    final selected = row['status'] == s;
                    final c = _statusColors[s]!;
                    return GestureDetector(
                      onTap: () => setState(() => row['status'] = s),
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected ? c : c.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(s,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : c)),
                        ),
                      ),
                    );
                  }).toList()),
                ),
              ]),
            );
          }),
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text('Save Attendance',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $count',
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, color: const Color(0xFF6B7280))),
    ]);
  }
}
