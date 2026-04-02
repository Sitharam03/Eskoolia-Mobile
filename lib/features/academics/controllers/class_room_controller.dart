import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class ClassRoomController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // List
  final items = <ClassRoom>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final message = ''.obs;

  // Form
  final editingId = RxnInt();
  final roomNo = ''.obs;
  final capacity = ''.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      error.value = '';
      items.value = await _repo.getClassRooms();
    } catch (e) {
      error.value = ApiError.extract(e, 'Unable to load classrooms.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (roomNo.value.trim().isEmpty) {
      error.value = 'Room number is required.';
      return;
    }
    try {
      isSaving.value = true;
      error.value = '';
      message.value = '';
      final capacityInt = capacity.value.trim().isEmpty
          ? null
          : int.tryParse(capacity.value.trim());
      await _repo.saveClassRoom(
        {
          'room_no': roomNo.value.trim(),
          'capacity': capacityInt,
          'active_status': true,
        },
        id: editingId.value,
      );
      message.value = editingId.value != null ? 'Classroom updated.' : 'Classroom added.';
      resetForm();
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to save classroom.');
    } finally {
      isSaving.value = false;
    }
  }

  void startEdit(ClassRoom room) {
    editingId.value = room.id;
    roomNo.value = room.roomNo;
    capacity.value = room.capacity?.toString() ?? '';
    error.value = '';
    message.value = '';
  }

  Future<void> delete(int id) async {
    try {
      error.value = '';
      await _repo.deleteClassRoom(id);
      await loadItems();
    } catch (e) {
      error.value = ApiError.extract(e, 'Failed to delete classroom.');
    }
  }

  void resetForm() {
    editingId.value = null;
    roomNo.value = '';
    capacity.value = '';
    error.value = '';
    message.value = '';
  }
}
