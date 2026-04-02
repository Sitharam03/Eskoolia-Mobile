import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../controllers/communication_controller.dart';
import 'notice_board_tab.dart';
import 'send_email_tab.dart';
import 'email_logs_tab.dart';
import 'holiday_calendar_tab.dart';

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

class CommunicationView extends StatelessWidget {
  const CommunicationView({super.key});

  CommunicationController get _c => Get.find<CommunicationController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Communication',
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              switch (_c.activeTab.value) {
                case 0:
                  return const NoticeBoardTab();
                case 1:
                  return const SendEmailTab();
                case 2:
                  return const EmailLogsTab();
                case 3:
                  return const HolidayCalendarTab();
                default:
                  return const NoticeBoardTab();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Notice Board', 'Send Email', 'Email Logs', 'Holidays'];
    const icons = [
      Icons.campaign_rounded,
      Icons.email_rounded,
      Icons.history_rounded,
      Icons.event_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPri.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: _kPri.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: List.generate(tabs.length, (i) {
              final active = _c.activeTab.value == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _c.activeTab.value = i,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(colors: [_kPri, _kVio])
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: _kPri.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icons[i],
                          size: 18,
                          color: active
                              ? Colors.white
                              : _kPri.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tabs[i],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          )),
    );
  }
}
