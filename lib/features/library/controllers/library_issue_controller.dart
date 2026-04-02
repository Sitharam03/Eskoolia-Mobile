import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../models/library_models.dart';
import '../repositories/library_repository.dart';

class LibraryIssueController extends GetxController {
  final _repo = LibraryRepository();

  final issues = <BookIssue>[].obs;
  final books = <Book>[].obs;
  final members = <LibraryMember>[].obs;
  final students = <LibraryStudent>[].obs;
  final staffList = <LibraryStaff>[].obs;

  // Issue form
  final selectedBookId = Rx<int?>(null);
  final selectedMemberId = Rx<int?>(null);
  final issueDate = ''.obs;
  final dueDate = ''.obs;

  // Filters
  final statusFilter = ''.obs; // '' | 'issued' | 'returned' | 'lost'
  final showOverdueOnly = false.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Default issue date to today
    final now = DateTime.now();
    issueDate.value =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final results = await Future.wait([
        _repo.getBooks(),
        _repo.getMembers(activeOnly: true),
        _repo.getStudents(),
        _repo.getStaff(),
        _repo.getIssues(),
      ]);
      books.value = results[0] as List<Book>;
      members.value = results[1] as List<LibraryMember>;
      students.value = results[2] as List<LibraryStudent>;
      staffList.value = results[3] as List<LibraryStaff>;
      issues.value = results[4] as List<BookIssue>;
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to load library issues.');
    } finally {
      isLoading.value = false;
    }
  }

  String bookLabel(int bookId) {
    final b = books.firstWhereOrNull((b) => b.id == bookId);
    if (b == null) return 'Book #$bookId';
    return '${b.title} (${b.availableQuantity}/${b.quantity})';
  }

  String memberLabel(int memberId) {
    final m = members.firstWhereOrNull((m) => m.id == memberId);
    if (m == null) return 'Member #$memberId';
    if (m.isStudent) {
      final s = students.firstWhereOrNull((s) => s.id == m.studentId);
      return '${m.cardNo} - ${s?.fullName ?? 'Student'}';
    } else {
      final s = staffList.firstWhereOrNull((s) => s.id == m.staffId);
      return '${m.cardNo} - ${s?.fullName ?? 'Staff'}';
    }
  }

  List<BookIssue> get filteredIssues {
    return issues.where((row) {
      if (statusFilter.value.isNotEmpty && row.status != statusFilter.value) {
        return false;
      }
      if (showOverdueOnly.value) {
        return row.isOverdue;
      }
      return true;
    }).toList();
  }

  void resetForm() {
    selectedBookId.value = null;
    selectedMemberId.value = null;
    final now = DateTime.now();
    issueDate.value =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    dueDate.value = '';
    errorMsg.value = '';
  }

  Future<void> issueBook() async {
    if (selectedBookId.value == null ||
        selectedMemberId.value == null ||
        issueDate.value.isEmpty ||
        dueDate.value.isEmpty) {
      errorMsg.value = 'Book, member, issue date and due date are required.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      await _repo.issueBook({
        'book': selectedBookId.value,
        'member': selectedMemberId.value,
        'issue_date': issueDate.value,
        'due_date': dueDate.value,
        'status': 'issued',
      });
      resetForm();
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to issue book.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> markReturned(BookIssue issue) async {
    try {
      errorMsg.value = '';
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await _repo.markReturned(issue.id, today);
      await load();
    } catch (e) {
      errorMsg.value = ApiError.extract(e, 'Unable to mark return.');
    }
  }
}
