import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '_student_nav_tabs.dart';

/// SMS Sending Time configuration screen.
/// Allows scheduling automated SMS notifications for students/parents.
class StudentSmsView extends StatefulWidget {
  const StudentSmsView({super.key});

  @override
  State<StudentSmsView> createState() => _StudentSmsViewState();
}

class _StudentSmsViewState extends State<StudentSmsView> {
  // Schedule toggles
  bool _attendanceSms = true;
  bool _feesDueSms = true;
  bool _examResultSms = false;
  bool _homeworkSms = false;
  bool _noticeSms = true;

  // Time settings
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);

  // Days of week
  final Set<int> _activeDays = {1, 2, 3, 4, 5}; // Mon–Fri
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _saving = false;
  String _successMsg = '';

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    setState(() { _saving = true; _successMsg = ''; });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() { _saving = false; _successMsg = 'SMS schedule saved successfully.'; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _successMsg = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: Text('SMS Sending Time', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          const StudentNavTabs(activeRoute: AppRoutes.studentSms),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('SMS Notification Types'),
                  const SizedBox(height: 8),
                  _toggleCard(
                    icon: Icons.how_to_reg_outlined,
                    title: 'Attendance SMS',
                    subtitle: 'Notify parents when student is marked absent or late',
                    value: _attendanceSms,
                    onChanged: (v) => setState(() => _attendanceSms = v),
                  ),
                  _toggleCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Fees Due SMS',
                    subtitle: 'Remind parents about pending fee payments',
                    value: _feesDueSms,
                    onChanged: (v) => setState(() => _feesDueSms = v),
                  ),
                  _toggleCard(
                    icon: Icons.assignment_outlined,
                    title: 'Exam Result SMS',
                    subtitle: 'Notify parents when exam results are published',
                    value: _examResultSms,
                    onChanged: (v) => setState(() => _examResultSms = v),
                  ),
                  _toggleCard(
                    icon: Icons.book_outlined,
                    title: 'Homework SMS',
                    subtitle: 'Alert parents about new homework assignments',
                    value: _homeworkSms,
                    onChanged: (v) => setState(() => _homeworkSms = v),
                  ),
                  _toggleCard(
                    icon: Icons.campaign_outlined,
                    title: 'Notice/Circular SMS',
                    subtitle: 'Send school notices and circulars via SMS',
                    value: _noticeSms,
                    onChanged: (v) => setState(() => _noticeSms = v),
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Sending Schedule'),
                  const SizedBox(height: 8),
                  _card(
                    child: Column(
                      children: [
                        _timeRow(
                          label: 'Morning Batch',
                          icon: Icons.wb_sunny_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          time: _morningTime,
                          onTap: () => _pickTime(_morningTime, (t) => setState(() => _morningTime = t)),
                        ),
                        const Divider(height: 1),
                        _timeRow(
                          label: 'Afternoon Batch',
                          icon: Icons.wb_cloudy_outlined,
                          iconColor: const Color(0xFF0284C7),
                          time: _afternoonTime,
                          onTap: () => _pickTime(_afternoonTime, (t) => setState(() => _afternoonTime = t)),
                        ),
                        const Divider(height: 1),
                        _timeRow(
                          label: 'Evening Batch',
                          icon: Icons.nightlight_round_outlined,
                          iconColor: const Color(0xFF7C3AED),
                          time: _eveningTime,
                          onTap: () => _pickTime(_eveningTime, (t) => setState(() => _eveningTime = t)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Active Days'),
                  const SizedBox(height: 8),
                  _card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(7, (i) {
                          final active = _activeDays.contains(i + 1);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (active) _activeDays.remove(i + 1);
                              else _activeDays.add(i + 1);
                            }),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: active ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _dayLabels[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Summary'),
                  const SizedBox(height: 8),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryRow('Morning Batch', _formatTime(_morningTime)),
                        _summaryRow('Afternoon Batch', _formatTime(_afternoonTime)),
                        _summaryRow('Evening Batch', _formatTime(_eveningTime)),
                        _summaryRow('Active Days',
                            _activeDays.isEmpty ? 'None'
                                : (_activeDays.toList()..sort()),
                        ),
                      ],
                    ),
                  ),
                  if (_successMsg.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF6EE7B7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF059669), size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_successMsg, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF065F46)))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Save Schedule', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1F2937))),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _toggleCard({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? const Color(0xFFC7D2FE) : const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: value ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1F2937))),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
        value: value,
        activeColor: const Color(0xFF4F46E5),
        onChanged: onChanged,
      ),
    );
  }

  Widget _timeRow({required String label, required IconData icon, required Color iconColor, required TimeOfDay time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF374151)))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_formatTime(time), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, dynamic value) {
    String display;
    if (value is List<int>) {
      display = value.map((d) => _dayLabels[d - 1]).join(', ');
    } else {
      display = value.toString();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
          Text(display, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
        ],
      ),
    );
  }
}
