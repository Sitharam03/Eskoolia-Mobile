import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/class_room_controller.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';

class ClassRoomView extends GetView<ClassRoomController> {
  const ClassRoomView({super.key});

  // TextEditingControllers kept here so they stay in sync with observable state.
  // We sync them via listeners in the build by reading from Obx.
  final _roomNoCtrl = const _RoomCtrlHolder();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Class Room',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsClassRoom),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                );
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: controller.loadItems,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _FormCard(c: controller),
                    const SizedBox(height: 12),
                    _Messages(c: controller),
                    _ItemList(c: controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Dummy holder to satisfy const constructor — actual controllers live inside the form widget.
class _RoomCtrlHolder {
  const _RoomCtrlHolder();
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatefulWidget {
  final ClassRoomController c;
  const _FormCard({required this.c});

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  late final TextEditingController _roomNoCtrl;
  late final TextEditingController _capacityCtrl;

  ClassRoomController get c => widget.c;

  @override
  void initState() {
    super.initState();
    _roomNoCtrl = TextEditingController(text: c.roomNo.value);
    _capacityCtrl = TextEditingController(text: c.capacity.value);

    // Sync controller → text field when editing starts
    ever(c.roomNo, (v) {
      if (_roomNoCtrl.text != v) {
        _roomNoCtrl.text = v;
      }
    });
    ever(c.capacity, (v) {
      if (_capacityCtrl.text != v) {
        _capacityCtrl.text = v;
      }
    });

    // Sync text field → controller
    _roomNoCtrl.addListener(() => c.roomNo.value = _roomNoCtrl.text);
    _capacityCtrl.addListener(() => c.capacity.value = _capacityCtrl.text);
  }

  @override
  void dispose() {
    _roomNoCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = c.editingId.value != null;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: aCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            aSectionHeader(isEditing ? 'Edit Classroom' : 'Add Classroom'),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 480;
              final roomField = aTextField(
                _roomNoCtrl,
                'Room No *',
                hint: 'e.g. 101',
              );
              final capacityField = aTextField(
                _capacityCtrl,
                'Capacity',
                hint: 'e.g. 40',
                keyboardType: TextInputType.number,
              );

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: roomField),
                    const SizedBox(width: 12),
                    Expanded(child: capacityField),
                  ],
                );
              }
              return Column(
                children: [
                  roomField,
                  const SizedBox(height: 12),
                  capacityField,
                ],
              );
            }),
            const SizedBox(height: 16),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: aSecondaryBtn('Cancel', () {
                      c.resetForm();
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: aPrimaryBtn(
                      'Update',
                      c.save,
                      isLoading: c.isSaving.value,
                    ),
                  ),
                ],
              )
            else
              aPrimaryBtn(
                'Add Classroom',
                c.save,
                isLoading: c.isSaving.value,
              ),
          ],
        ),
      );
    });
  }
}

// ── Messages ──────────────────────────────────────────────────────────────────

class _Messages extends StatelessWidget {
  final ClassRoomController c;
  const _Messages({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.error.value.isNotEmpty) {
        return _banner(c.error.value, const Color(0xFFFEE2E2),
            const Color(0xFFDC2626), Icons.error_outline_rounded);
      }
      if (c.message.value.isNotEmpty) {
        return _banner(c.message.value, const Color(0xFFD1FAE5),
            const Color(0xFF059669), Icons.check_circle_outline_rounded);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _banner(String text, Color bg, Color fg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: fg, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Item list ─────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final ClassRoomController c;
  const _ItemList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: aSavingIndicator(),
        );
      }
      if (c.items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child:
              aEmptyState('No classrooms yet.\nUse the form above to add one.'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: aSectionHeader('Classrooms (${c.items.length})'),
          ),
          ...c.items.map((room) {
            return aInfoCard(
              title: 'Room ${room.roomNo}',
              subtitle:
                  'Capacity: ${room.capacity != null ? room.capacity.toString() : '-'}',
              trailing: aBadge(
                room.activeStatus ? 'Active' : 'Inactive',
                room.activeStatus
                    ? const Color(0xFF059669)
                    : const Color(0xFF6B7280),
              ),
              onEdit: () => c.startEdit(room),
              onDelete: () async {
                final ok = await aDeleteDialog(
                  context,
                  'Delete Room ${room.roomNo}?',
                );
                if (ok) c.delete(room.id);
              },
            );
          }),
        ],
      );
    });
  }
}
