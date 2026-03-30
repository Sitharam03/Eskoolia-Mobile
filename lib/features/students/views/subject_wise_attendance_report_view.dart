import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '_student_nav_tabs.dart';

class SubjectWiseAttendanceReportView extends StatefulWidget {
  const SubjectWiseAttendanceReportView({super.key});

  @override
  State<SubjectWiseAttendanceReportView> createState() =>
      _SubjectWiseAttendanceReportViewState();
}

class _SubjectWiseAttendanceReportViewState
    extends State<SubjectWiseAttendanceReportView> {
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  // Demo summary data
  final _summary = [
    {
      'name': 'Alice Johnson',
      'roll': '01',
      'total': 30,
      'present': 28,
      'absent': 2,
      'leave': 0
    },
    {
      'name': 'Bob Smith',
      'roll': '02',
      'total': 30,
      'present': 20,
      'absent': 8,
      'leave': 2
    },
    {
      'name': 'Carol White',
      'roll': '03',
      'total': 30,
      'present': 30,
      'absent': 0,
      'leave': 0
    },
    {
      'name': 'David Brown',
      'roll': '04',
      'total': 30,
      'present': 25,
      'absent': 3,
      'leave': 2
    },
    {
      'name': 'Eva Davis',
      'roll': '05',
      'total': 30,
      'present': 15,
      'absent': 12,
      'leave': 3
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Subject Wise Attendance Report',
      body: Column(
        children: [
          const StudentNavTabs(
              activeRoute: AppRoutes.studentSubjectWiseAttendanceReport),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter card
                  _filterCard(context),
                  const SizedBox(height: 14),
                  // Summary cards row
                  _summaryRow(),
                  const SizedBox(height: 14),
                  // Report table
                  _reportTable(),
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
              Text('Filter Report',
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
                  Expanded(
                      child: _dropdown('Class', _selectedClass,
                          ['Class 1', 'Class 2', 'Class 3'],
                          (v) => setState(() => _selectedClass = v))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _dropdown('Section', _selectedSection,
                          ['A', 'B', 'C'],
                          (v) => setState(() => _selectedSection = v))),
                ]),
                const SizedBox(height: 10),
                _dropdown('Subject', _selectedSubject,
                    ['Mathematics', 'Science', 'English'],
                    (v) => setState(() => _selectedSubject = v)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _datePicker('From', _from,
                          (d) => setState(() => _from = d), context)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _datePicker('To', _to,
                          (d) => setState(() => _to = d), context)),
                ]),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: Text('Generate Report',
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

  Widget _summaryRow() {
    final totalStudents = _summary.length;
    final avgPresent = _summary.isEmpty
        ? 0.0
        : _summary
                .map((r) =>
                    (r['present'] as int) / (r['total'] as int) * 100)
                .reduce((a, b) => a + b) /
            totalStudents;

    return Row(children: [
      Expanded(
          child: _statCard('Students', '$totalStudents',
              Icons.people_outline, const Color(0xFF4F46E5))),
      const SizedBox(width: 10),
      Expanded(
          child: _statCard('Avg Attendance',
              '${avgPresent.toStringAsFixed(1)}%',
              Icons.percent, const Color(0xFF10B981))),
      const SizedBox(width: 10),
      Expanded(
          child: _statCard('Period',
              '${_summary.isNotEmpty ? (_summary[0]['total']) : 0} days',
              Icons.calendar_month_outlined, const Color(0xFF0EA5E9))),
    ]);
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827))),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _reportTable() {
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
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.table_chart_outlined,
                    size: 16, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 10),
              Text('Student Report',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.download_outlined,
                        size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text('Export',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981))),
                  ]),
                ),
              ),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            color: const Color(0xFFF3F4F6),
            child: Row(children: [
              SizedBox(
                  width: 28,
                  child: Text('#',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
              Expanded(
                  child: Text('Name',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
              SizedBox(
                  width: 32,
                  child: Text('P',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981)))),
              SizedBox(
                  width: 32,
                  child: Text('A',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEF4444)))),
              SizedBox(
                  width: 32,
                  child: Text('L',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B)))),
              SizedBox(
                  width: 44,
                  child: Text('%',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151)))),
            ]),
          ),
          ..._summary.asMap().entries.map((e) {
            final r = e.value;
            final pct =
                (r['present'] as int) / (r['total'] as int) * 100;
            final pctColor = pct >= 75
                ? const Color(0xFF10B981)
                : pct >= 50
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444);
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: e.key.isEven
                    ? Colors.white
                    : const Color(0xFFFAFAFA),
                border: e.key < _summary.length - 1
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF3F4F6)))
                    : null,
                borderRadius: e.key == _summary.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(13))
                    : null,
              ),
              child: Row(children: [
                SizedBox(
                  width: 28,
                  child: Text(r['roll'].toString(),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF))),
                ),
                Expanded(
                  child: Text(r['name'].toString(),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827))),
                ),
                SizedBox(
                  width: 32,
                  child: Text('${r['present']}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981))),
                ),
                SizedBox(
                  width: 32,
                  child: Text('${r['absent']}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444))),
                ),
                SizedBox(
                  width: 32,
                  child: Text('${r['leave']}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF59E0B))),
                ),
                SizedBox(
                  width: 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 3),
                    decoration: BoxDecoration(
                        color: pctColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('${pct.toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: pctColor)),
                  ),
                ),
              ]),
            );
          }),
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

  Widget _datePicker(String label, DateTime value,
      ValueChanged<DateTime> onChanged, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF111827)),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
