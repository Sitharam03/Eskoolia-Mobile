import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_result_publish_controller.dart';
import '_exam_nav_tabs.dart';

class ExamResultPublishView extends StatelessWidget {
  const ExamResultPublishView({super.key});

  ExamResultPublishController get _c => Get.find<ExamResultPublishController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examResultPublish),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.search,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _SearchCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(msg: _c.errorMsg.value, isError: true),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.successMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(msg: _c.successMsg.value, isError: false),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.result.value != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _ResultCard(c: _c),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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
}

class _SearchCard extends StatelessWidget {
  final ExamResultPublishController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Search Result'),
        const SizedBox(height: 16),
        Obx(() => Column(children: [
              sFieldLabel('Exam'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedExamId.value,
                hint: 'Select Exam',
                items: c.examTypes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.title)))
                    .toList(),
                onChanged: (v) => c.selectedExamId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Class'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedClassId.value,
                hint: 'Select Class',
                items: c.classes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedClassId.value = v;
                  c.selectedSectionId.value = null;
                },
              ),
              const SizedBox(height: 12),
              sFieldLabel('Section (Optional)'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSectionId.value,
                hint: 'All Sections',
                items: c.filteredSections
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSectionId.value = v,
              ),
            ])),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isSearching.value ? null : c.search,
                icon: c.isSearching.value
                    ? sSavingIndicator()
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(c.isSearching.value ? 'Searching…' : 'Search',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
        ),
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ExamResultPublishController c;
  const _ResultCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final r = c.result.value!;
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Result Details'),
        const SizedBox(height: 16),
        _InfoRow(label: 'Exam', value: r.examName),
        _InfoRow(label: 'Class', value: r.className),
        _InfoRow(label: 'Section', value: r.sectionName),
        _InfoRow(label: 'Total Entries', value: r.totalMarkEntries.toString()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: r.isPublished
                ? const Color(0xFF059669).withValues(alpha: 0.08)
                : const Color(0xFFEA580C).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(
              r.isPublished
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: r.isPublished
                  ? const Color(0xFF059669)
                  : const Color(0xFFEA580C),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                r.isPublished
                    ? 'Published${r.publishedAt != null ? ' on ${r.publishedAt}' : ''}'
                    : 'Not Published',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: r.isPublished
                      ? const Color(0xFF059669)
                      : const Color(0xFFEA580C),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: c.isPublishing.value || r.isPublished
                      ? null
                      : () => _confirmAction(
                            context,
                            'Publish Result',
                            'Are you sure you want to publish this result? Students will be able to view it.',
                            c.publish,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: c.isPublishing.value
                      ? sSavingIndicator()
                      : Text('Publish',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => OutlinedButton(
                  onPressed: c.isPublishing.value || !r.isPublished
                      ? null
                      : () => _confirmAction(
                            context,
                            'Unpublish Result',
                            'Are you sure you want to unpublish this result?',
                            c.unpublish,
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Unpublish',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                )),
          ),
        ]),
      ]),
    );
  }

  void _confirmAction(BuildContext context, String title, String message,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => sConfirmDialog(
        context: context,
        title: title,
        message: message,
        confirmLabel: 'Confirm',
        confirmColor: const Color(0xFF4F46E5),
        onConfirm: onConfirm,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF6B7280))),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827))),
      ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String msg;
  final bool isError;
  const _StatusBanner({required this.msg, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(fontSize: 13, color: color))),
      ]),
    );
  }
}
