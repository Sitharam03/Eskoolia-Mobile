import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_carry_forward_controller.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';

class FeesCarryForwardView extends StatelessWidget {
  const FeesCarryForwardView({super.key});

  FeesCarryForwardController get _c =>
      Get.find<FeesCarryForwardController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Carry Forward',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesCarryForward),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildFormCard(context),
                  const SizedBox(height: 16),
                  Obx(() {
                    final res = _c.result.value;
                    if (res == null) return const SizedBox.shrink();
                    return _buildResultCard(res);
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kFeesPrimary.withOpacity(0.08),
            kFeesTeal.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kFeesPrimary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kFeesPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline,
                size: 22, color: kFeesPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About Carry Forward',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kFeesPrimary)),
                const SizedBox(height: 6),
                Text(
                  'Transfer all unpaid and partial fee balances from one academic year to another. '
                  'Existing assignments in the target year will have the carry-forward amount added to them. '
                  'New assignments will be created where none exist.',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: fCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Carry Forward Settings',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // From Year
          fLabel('From Academic Year *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select source year',
                value: _c.fromYearId.value,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Select year')),
                  ..._c.academicYears.map((y) => DropdownMenuItem(
                      value: y.id, child: Text(y.title))),
                ],
                onChanged: (v) => _c.fromYearId.value = v,
              )),
          const SizedBox(height: 16),

          // Arrow indicator
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kFeesPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward,
                  size: 20, color: kFeesPrimary),
            ),
          ),
          const SizedBox(height: 16),

          // To Year
          fLabel('To Academic Year *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select target year',
                value: _c.toYearId.value,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Select year')),
                  ..._c.academicYears.map((y) => DropdownMenuItem(
                      value: y.id, child: Text(y.title))),
                ],
                onChanged: (v) => _c.toYearId.value = v,
              )),
          const SizedBox(height: 16),

          // Due date
          fLabel('Due Date for Carried Assignments'),
          fTextField(
            _c.dueDateCtrl,
            'YYYY-MM-DD',
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.tryParse(_c.dueDateCtrl.text) ??
                        DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                _c.dueDateCtrl.text =
                    picked.toIso8601String().split('T').first;
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Defaults to today if left unchanged.',
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),

          // Buttons
          Obx(() => fPrimaryBtn(
                label: 'Execute Carry Forward',
                loading: _c.isLoading.value,
                onPressed: _c.carryForward,
              )),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _c.resetForm,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Reset',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> res) {
    final created = res['created'] ?? 0;
    final updated = res['updated'] ?? 0;
    final total = res['total_amount'] ?? '0.00';
    final message = (res['message'] as String?) ?? 'Completed';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: kFeesGreen, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kFeesGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _resultStat('New Assignments', '$created',
                    kFeesPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resultStat('Updated', '$updated', kFeesAmber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resultStat(
                    'Total Amount', '₹ $total', kFeesTeal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF6B7280))),
          ],
        ),
      );
}
