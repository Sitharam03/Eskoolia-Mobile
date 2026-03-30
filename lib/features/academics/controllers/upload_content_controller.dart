import 'package:get/get.dart';
import '../repositories/academics_repository.dart';
import '../models/academics_models.dart';

class UploadContentController extends GetxController {
  final _repo = Get.find<AcademicsRepository>();

  // Content type constants
  static const Map<String, String> contentTypes = {
    'as': 'Assignment',
    'st': 'Study Material',
    'sy': 'Syllabus',
    'ot': 'Other Downloads',
  };

  // Lookups
  final years = <AcademicYear>[].obs;
  final classes = <SchoolClass>[].obs;
  final sections = <Section>[].obs;

  // ── Upload form ────────────────────────────────────────────────────────────
  final academicYearId = ''.obs;
  final classId = ''.obs;
  final sectionId = ''.obs;
  final contentTitle = ''.obs;
  final contentType = 'as'.obs;
  final uploadDate = _today().obs;
  final description = ''.obs;
  final sourceUrl = ''.obs;
  final uploadFile = ''.obs;
  final forAdmin = false.obs;
  final forAllClasses = false.obs;
  final isSaving = false.obs;
  final uploadError = ''.obs;
  final uploadSuccess = ''.obs;

  // ── List ───────────────────────────────────────────────────────────────────
  final items = <UploadedContent>[].obs;
  final isLoading = false.obs;
  final filterClassId = ''.obs;
  final filterSectionId = ''.obs;
  final listContentType = ''.obs;
  final editing = Rx<UploadedContent?>(null);
  final viewing = Rx<UploadedContent?>(null);
  final listError = ''.obs;

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Section> get filteredSections =>
      sections.where((s) => s.schoolClass == int.tryParse(classId.value)).toList();

  List<Section> get filterSections =>
      sections.where((s) => s.schoolClass == int.tryParse(filterClassId.value)).toList();

  String contentTypeName(String? code) =>
      code == null ? '-' : (contentTypes[code] ?? code);

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
    loadItems();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _repo.getAcademicYears(),
      _repo.getClasses(),
      _repo.getSections(),
    ]);
    years.value = results[0] as List<AcademicYear>;
    classes.value = results[1] as List<SchoolClass>;
    sections.value = results[2] as List<Section>;
    if (academicYearId.isEmpty && years.isNotEmpty) {
      final current = years.firstWhereOrNull((y) => y.isCurrent);
      academicYearId.value = current != null
          ? current.id.toString()
          : years.first.id.toString();
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> submitUpload() async {
    if (contentTitle.value.trim().isEmpty) {
      uploadError.value = 'Content title is required.';
      return;
    }
    if (sourceUrl.value.trim().isEmpty && uploadFile.value.trim().isEmpty) {
      uploadError.value = 'Please provide a URL or file.';
      return;
    }
    try {
      isSaving.value = true;
      uploadError.value = '';
      uploadSuccess.value = '';
      await _repo.createUploadedContent({
        'academic_year_id': academicYearId.isNotEmpty ? int.parse(academicYearId.value) : null,
        'class_id': forAllClasses.value || classId.isEmpty ? null : int.parse(classId.value),
        'section_id': forAllClasses.value || sectionId.isEmpty ? null : int.parse(sectionId.value),
        'content_title': contentTitle.value.trim(),
        'content_type': contentType.value,
        'upload_date': uploadDate.value,
        'description': description.value.isNotEmpty ? description.value : null,
        'source_url': sourceUrl.value.isNotEmpty ? sourceUrl.value : null,
        'upload_file': uploadFile.value.isNotEmpty ? uploadFile.value : null,
        'for_admin': forAdmin.value,
        'for_all_classes': forAllClasses.value,
      });
      uploadSuccess.value = 'Content uploaded successfully.';
      _resetForm();
      await loadItems();
    } catch (_) {
      uploadError.value = 'Failed to upload content.';
    } finally {
      isSaving.value = false;
    }
  }

  void _resetForm() {
    classId.value = '';
    sectionId.value = '';
    contentTitle.value = '';
    contentType.value = 'as';
    uploadDate.value = _today();
    description.value = '';
    sourceUrl.value = '';
    uploadFile.value = '';
    forAdmin.value = false;
    forAllClasses.value = false;
    uploadError.value = '';
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Future<void> loadItems({String? lockedType}) async {
    try {
      isLoading.value = true;
      listError.value = '';
      final effectiveType = lockedType ?? (listContentType.value.isNotEmpty ? listContentType.value : null);
      items.value = await _repo.getUploadedContents(
        classId: filterClassId.value.isEmpty ? null : filterClassId.value,
        sectionId: filterSectionId.value.isEmpty ? null : filterSectionId.value,
        contentType: effectiveType,
      );
    } catch (_) {
      listError.value = 'Unable to load uploaded content.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      listError.value = '';
      await _repo.deleteUploadedContent(id);
      await loadItems();
    } catch (_) {
      listError.value = 'Failed to delete content.';
    }
  }

  // ── Edit ───────────────────────────────────────────────────────────────────

  void startEdit(UploadedContent item) {
    editing.value = item;
    listError.value = '';
  }

  Future<void> saveEdit() async {
    final item = editing.value;
    if (item == null) return;
    try {
      isSaving.value = true;
      listError.value = '';
      await _repo.patchUploadedContent(item.id, {
        'academic_year_id': item.academicYearId,
        'class_id': item.classId,
        'section_id': item.sectionId,
        'content_title': item.contentTitle,
        'content_type': item.contentType,
        'upload_date': item.uploadDate,
        'description': item.description,
        'source_url': item.sourceUrl,
        'upload_file': item.uploadFile,
        'available_for_admin': item.availableForAdmin,
        'available_for_all_classes': item.availableForAllClasses,
      });
      editing.value = null;
      await loadItems();
    } catch (_) {
      listError.value = 'Failed to update content.';
    } finally {
      isSaving.value = false;
    }
  }
}
