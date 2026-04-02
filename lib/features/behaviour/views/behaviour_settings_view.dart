import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_settings_controller.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';
import '../../../core/widgets/school_loader.dart';

class BehaviourSettingsView extends StatefulWidget {
  const BehaviourSettingsView({super.key});

  @override
  State<BehaviourSettingsView> createState() => _BehaviourSettingsViewState();
}

class _BehaviourSettingsViewState extends State<BehaviourSettingsView> {
  late final BehaviourSettingsController _c;

  bool _studentComment = false;
  bool _parentComment = false;
  bool _studentView = false;
  bool _parentView = false;

  @override
  void initState() {
    super.initState();
    _c = Get.find<BehaviourSettingsController>();
    _syncFromSetting();
    // Keep local toggles in sync whenever the controller refreshes the setting
    ever(_c.setting, (_) {
      if (mounted) setState(() => _syncFromSetting());
    });
  }

  void _syncFromSetting() {
    final s = _c.setting.value;
    _studentComment = s.studentComment;
    _parentComment = s.parentComment;
    _studentView = s.studentView;
    _parentView = s.parentView;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(activeRoute: AppRoutes.behaviourSettings),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildToggles(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: bCardDecoration(borderColor: kBehPrimary.withOpacity(0.25)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kBehPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded,
                color: kBehPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Behaviour Visibility Settings',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Control who can view and comment on behaviour records.',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: kBehGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggles() {
    return Container(
      decoration: bCardDecoration(),
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.person_outline,
            iconColor: kBehBlue,
            title: 'Student View',
            subtitle:
                'Allow students to view their own behaviour records',
            value: _studentView,
            onChanged: (v) => setState(() => _studentView = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingTile(
            icon: Icons.family_restroom_outlined,
            iconColor: kBehGreen,
            title: 'Parent View',
            subtitle:
                "Allow parents to view their child's behaviour records",
            value: _parentView,
            onChanged: (v) => setState(() => _parentView = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingTile(
            icon: Icons.comment_outlined,
            iconColor: kBehAmber,
            title: 'Student Comments',
            subtitle:
                'Allow students to comment on behaviour assignments',
            value: _studentComment,
            onChanged: (v) => setState(() => _studentComment = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingTile(
            icon: Icons.chat_bubble_outline,
            iconColor: kBehPrimary,
            title: 'Parent Comments',
            subtitle:
                'Allow parents to comment on behaviour assignments',
            value: _parentComment,
            onChanged: (v) => setState(() => _parentComment = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => bPrimaryBtn(
          label: 'Save Settings',
          loading: _c.isSaving.value,
          icon: Icons.save_outlined,
          onPressed: () => _c.saveSetting(
            studentComment: _studentComment,
            parentComment: _parentComment,
            studentView: _studentView,
            parentView: _parentView,
          ),
        ));
  }
}

// ── Setting tile ──────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
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
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: kBehGray)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBehPrimary,
          ),
        ],
      ),
    );
  }
}
