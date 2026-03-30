import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '_student_nav_tabs.dart';

class SubjectWiseAttendanceView extends StatefulWidget {
  const SubjectWiseAttendanceView({super.key});

  @override
  State<SubjectWiseAttendanceView> createState() =>
      _SubjectWiseAttendanceViewState();
}

class _SubjectWiseAttendanceViewState
    extends State<SubjectWiseAttendanceView> {
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  DateTime _date = DateTime.now();

  static const _statusColors = {
    'P': Color(0xFF10B981),
    'A': Color(0xFFEF4444),
    'L': Color(0xFFF59E0B),
  };

  // Demo rows — will be replaced by real API data
  final _rows = <Map<String, String>>[
    {'roll': '01', 'name': 'Alice Johnson', 'status': 'P'},
    {'roll': '02', 'name': 'Bob Smith', 'status': 'A'},
    {'roll': '03', 'name': 'Carol White', 'status': 'P'},
    {'roll': '04', 'name': 'David Brown', 'status': 'L'},
    {'roll': '05', 'name': 'Eva Davis', 'status': 'P'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Subject Wise Attendance',
      body: Column(
        children: [
          const StudentNavTabs(
              activeRoute: AppRoutes.studentSubjectWiseAttendance),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter card
                  _filterCard(context),
                  const SizedBox(height: 14),
                  // Attendance table
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.filter_list,
                    size: 16, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text('Filter',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: _dropdown('Class', _selectedClass,
                      ['Class 1', 'Class 2', 'Class 3'],
                      (v) => setState(() => _selectedClass = v))),
                  const SizedBox(width: 10),
                  Expanded(child: _dropdown('Section', _selectedSection,
                      ['A', 'B', 'C'],
                      (v) => setState(() => _selectedSection = v))),
                ]),
                const SizedBox(height: 10),
                _dropdown('Subject', _selectedSubject,
                    ['Mathematics', 'Science', 'English'],
                    (v) => setState(() => _selectedSubject = v)),
                const SizedBox(height: 10),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 15, color: Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF111827)),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 18),
                    label: Text('Load Attendance',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
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

  Widget _dropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFF4F46E5), width: 1.5)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            isDense: true,
            hintText: 'Select $label',
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF9CA3AF)),
          ),
          style:
              GoogleFonts.inter(fontSize: 13, color: const Color(0xFF111827)),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
        ),
      ],
    );
  }

  Widget _attendanceTable() {
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
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.how_to_reg_outlined,
                    size: 16, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Text('Attendance Sheet',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              // Legend
              _legend('P', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _legend('A', const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _legend('L', const Color(0xFFF59E0B)),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Table header
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
              Text('Status',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151))),
            ]),
          ),
          // Rows
          ..._rows.asMap().entries.map((e) {
            final row = e.value;
            final statusColor =
                _statusColors[row['status']] ?? const Color(0xFF6B7280);
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    e.key.isEven ? Colors.white : const Color(0xFFFAFAFA),
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
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827))),
                ),
                // Status toggle buttons
                Row(children: ['P', 'A', 'L'].map((s) {
                  final selected = row['status'] == s;
                  final c = _statusColors[s]!;
                  return GestureDetector(
                    onTap: () => setState(() => row['status'] = s),
                    child: Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected
                            ? c
                            : c.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(s,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : c)),
                      ),
                    ),
                  );
                }).toList()),
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

  Widget _legend(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151))),
        ],
      );
}
