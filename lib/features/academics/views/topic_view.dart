import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/topic_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';

class TopicView extends GetView<TopicController> {
  const TopicView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Topics',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsTopics),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TopicCreateForm(controller: controller),
                  const SizedBox(height: 16),
                  _TopicGroupsList(controller: controller),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 1: Create form ────────────────────────────────────────────────────

class _TopicCreateForm extends StatefulWidget {
  final TopicController controller;
  const _TopicCreateForm({required this.controller});

  @override
  State<_TopicCreateForm> createState() => _TopicCreateFormState();
}

class _TopicCreateFormState extends State<_TopicCreateForm> {
  TopicController get c => widget.controller;
  late final TextEditingController _topicTextCtrl;

  @override
  void initState() {
    super.initState();
    _topicTextCtrl = TextEditingController(text: c.topicText.value);
  }

  @override
  void dispose() {
    _topicTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Create Topics',
      icon: Icons.topic_rounded,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Year
              aDropdown<String>(
                value: c.academicYearId.value.isEmpty
                    ? null
                    : c.academicYearId.value,
                label: 'Academic Year',
                items: [
                  _none(),
                  ...c.years.map((y) => _dd(y.id.toString(), y.name)),
                ],
                onChanged: (v) => c.academicYearId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Class *
              aDropdown<String>(
                value: c.classId.value.isEmpty ? null : c.classId.value,
                label: 'Class *',
                items: c.classes
                    .map((cl) => _dd(cl.id.toString(), cl.name))
                    .toList(),
                onChanged: (v) {
                  c.classId.value = v ?? '';
                  c.sectionId.value = '';
                  c.subjectId.value = '';
                  c.lessonId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Section
              aDropdown<String>(
                value: c.sectionId.value.isEmpty ? null : c.sectionId.value,
                label: 'Section',
                items: [
                  _none(),
                  ...c.filteredSections
                      .map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) {
                  c.sectionId.value = v ?? '';
                  c.lessonId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Subject *
              aDropdown<String>(
                value: c.subjectId.value.isEmpty ? null : c.subjectId.value,
                label: 'Subject *',
                items: c.subjects
                    .map((s) => _dd(s.id.toString(), s.name))
                    .toList(),
                onChanged: (v) {
                  c.subjectId.value = v ?? '';
                  c.lessonId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Lesson *
              aDropdown<String>(
                value: c.lessonId.value.isEmpty ? null : c.lessonId.value,
                label: 'Lesson *',
                items: c.filteredLessons
                    .map((l) => _dd(l.id.toString(), l.lessonTitle))
                    .toList(),
                onChanged: (v) {
                  c.lessonId.value = v ?? '';
                  c.loadTopicGroups();
                  c.loadTopicDetails();
                },
              ),
              const SizedBox(height: 14),

              // Topic titles textarea
              aTextField(
                _topicTextCtrl,
                'Topic Titles (one per line)',
                hint: 'e.g.\nChapter 1: Variables\nChapter 2: Equations',
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Error / success
              if (c.error.value.isNotEmpty)
                _StatusBanner(message: c.error.value, isError: true),
              if (c.message.value.isNotEmpty)
                _StatusBanner(message: c.message.value, isError: false),

              SizedBox(
                width: double.infinity,
                child: aPrimaryBtn(
                  c.isSaving.value ? 'Saving...' : 'Save Topics',
                  c.isSaving.value
                      ? null
                      : () async {
                          c.topicText.value = _topicTextCtrl.text;
                          await c.submitTopics();
                          if (c.error.value.isEmpty) {
                            _topicTextCtrl.clear();
                          }
                        },
                  isLoading: c.isSaving.value,
                ),
              ),
            ],
          )),
    );
  }

  static DropdownMenuItem<String> _none() =>
      DropdownMenuItem(
          value: '',
          child: Text('-- None --',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));

  static DropdownMenuItem<String> _dd(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF111827))));
}

// ── Section 2: Topic groups list ──────────────────────────────────────────────

class _TopicGroupsList extends StatelessWidget {
  final TopicController controller;
  const _TopicGroupsList({required this.controller});

  TopicController get c => controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Topic Groups',
      icon: Icons.layers_rounded,
      child: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            ),
          );
        }
        if (c.topicGroups.isEmpty) {
          return aEmptyState(
              'No topic groups.\nSelect a lesson to load topics.');
        }
        return Column(
          children: c.topicGroups
              .map((group) => _TopicGroupTile(group: group, controller: c))
              .toList(),
        );
      }),
    );
  }
}

class _TopicGroupTile extends StatelessWidget {
  final LessonTopicGroup group;
  final TopicController controller;
  const _TopicGroupTile(
      {required this.group, required this.controller});

  TopicController get c => controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Group #${group.id}  •  ${c.lessonTitle(group.lessonId)}',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: const Color(0xFF4F46E5)),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    _confirmDeleteGroup(context, group.id),
                icon: const Icon(Icons.delete_sweep_rounded,
                    size: 16, color: Color(0xFFDC2626)),
                label: Text('Delete Group',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ]),
          ),

          // Topics
          if (group.topics.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text('No topic details.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF9CA3AF))),
            )
          else
            ...group.topics.map((td) => _TopicDetailRow(
                  topicDetail: td,
                  controller: c,
                )),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, int groupId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Topic Group',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Delete all topics in group #$groupId?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              c.deleteTopicGroup(groupId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _TopicDetailRow extends StatefulWidget {
  final LessonTopicDetail topicDetail;
  final TopicController controller;
  const _TopicDetailRow(
      {required this.topicDetail, required this.controller});

  @override
  State<_TopicDetailRow> createState() => _TopicDetailRowState();
}

class _TopicDetailRowState extends State<_TopicDetailRow> {
  late final TextEditingController _editCtrl;
  TopicController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _editCtrl =
        TextEditingController(text: widget.topicDetail.topicTitle);
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = c.editingTopicId.value == widget.topicDetail.id;
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: const Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB))),
          color: isEditing ? const Color(0xFFF5F3FF) : Colors.white,
        ),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? aTextField(_editCtrl, '', hint: 'Topic title')
                : Text(widget.topicDetail.topicTitle,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF374151))),
          ),
          const SizedBox(width: 8),
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check_rounded,
                  color: Color(0xFF16A34A), size: 20),
              onPressed: () {
                c.editingTopicTitle.value = _editCtrl.text;
                c.saveTopicTitle();
              },
              visualDensity: VisualDensity.compact,
              tooltip: 'Save',
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Color(0xFF6B7280), size: 20),
              onPressed: () {
                c.editingTopicId.value = null;
                _editCtrl.text = widget.topicDetail.topicTitle;
              },
              visualDensity: VisualDensity.compact,
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: Color(0xFF4F46E5), size: 18),
              onPressed: () {
                _editCtrl.text = widget.topicDetail.topicTitle;
                c.startEditTopic(widget.topicDetail);
              },
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 18),
              onPressed: () => _confirmDelete(context),
              visualDensity: VisualDensity.compact,
              tooltip: 'Delete',
            ),
          ],
        ]),
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Topic',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Delete "${widget.topicDetail.topicTitle}"?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              c.deleteTopicDetail(widget.topicDetail.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Shared section card ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F3FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF4F46E5), size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF4F46E5))),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final bg =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: GoogleFonts.inter(
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
