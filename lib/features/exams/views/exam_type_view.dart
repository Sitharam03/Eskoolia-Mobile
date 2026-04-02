import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/students/views/_student_shared.dart';
import '../controllers/exam_type_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class ExamTypeView extends StatelessWidget {
  const ExamTypeView({super.key});

  ExamTypeController get _c => Get.find<ExamTypeController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examType),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.loadExamTypes,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExamTypeForm(c: _c),
                      const SizedBox(height: 16),
                      _ExamTypeList(c: _c),
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

// ── Form Card ────────────────────────────────────────────────────────────────

class _ExamTypeForm extends StatefulWidget {
  final ExamTypeController c;
  const _ExamTypeForm({required this.c});

  @override
  State<_ExamTypeForm> createState() => _ExamTypeFormState();
}

class _ExamTypeFormState extends State<_ExamTypeForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _avgMarkCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _avgMarkCtrl = TextEditingController(text: '0.00');

    ever(widget.c.titleCtrl, (v) {
      if (_titleCtrl.text != v) _titleCtrl.text = v;
    });
    ever(widget.c.averageMark, (v) {
      if (_avgMarkCtrl.text != v) _avgMarkCtrl.text = v;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _avgMarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                c.isEditing ? 'Edit Exam Type' : 'Add Exam Type',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827)),
              )),
          const SizedBox(height: 14),
          sFieldLabel('Exam Name *'),
          const SizedBox(height: 6),
          sTextField(
            controller: _titleCtrl,
            hint: 'Enter exam name',
            onChanged: (v) => c.titleCtrl.value = v,
          ),
          const SizedBox(height: 12),
          Obx(() => _CheckboxRow(
                label: 'Average Passing Examination',
                value: c.isAverage.value,
                onChanged: (v) => c.isAverage.value = v ?? false,
              )),
          Obx(() {
            if (!c.isAverage.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                sFieldLabel('Average Mark *'),
                const SizedBox(height: 6),
                sTextField(
                  controller: _avgMarkCtrl,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => c.averageMark.value = v,
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: c.isSaving.value ? null : c.save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: c.isSaving.value
                          ? sSavingIndicator()
                          : Text(
                              c.isEditing ? 'Update Exam Type' : 'Save Exam Type',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                    ),
                  ),
                  if (c.isEditing) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: c.cancelEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ]
                ],
              )),
        ],
      ),
    );
  }
}

// ── List Card ────────────────────────────────────────────────────────────────

class _ExamTypeList extends StatelessWidget {
  final ExamTypeController c;
  const _ExamTypeList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'Exam Type List',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827)),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (c.examTypes.isEmpty) {
              return sEmptyState(
                  'No exam types found.\nAdd one above.', Icons.quiz_outlined);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.examTypes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
              itemBuilder: (_, i) => _ExamTypeRow(
                index: i,
                type: c.examTypes[i],
                onEdit: () => c.startEdit(c.examTypes[i].id),
                onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                    context: context,
                    message:
                        'Delete exam type "${c.examTypes[i].title}"?',
                    onConfirm: () => c.delete(c.examTypes[i].id),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ExamTypeRow extends StatelessWidget {
  final int index;
  final ExamType type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExamTypeRow({
    required this.index,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  sBadge(
                    type.isAverage ? 'Average: Yes' : 'Average: No',
                    type.isAverage
                        ? const Color(0xFF059669)
                        : const Color(0xFF6B7280),
                  ),
                  if (type.isAverage) ...[
                    const SizedBox(width: 6),
                    sBadge('Mark: ${double.tryParse(type.averageMark)?.toStringAsFixed(2) ?? type.averageMark}',
                        const Color(0xFF0EA5E9)),
                  ],
                ]),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF4F46E5), size: 20),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626), size: 20),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF374151))),
            ],
          ),
        ),
      );
}
