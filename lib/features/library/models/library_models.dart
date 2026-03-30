// ── Book Category ─────────────────────────────────────────────────────────────

class BookCategory {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const BookCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) => BookCategory(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isActive: json['is_active'] == true,
      );
}

// ── Book ──────────────────────────────────────────────────────────────────────

class Book {
  final int id;
  final int? categoryId;
  final String title;
  final String author;
  final String isbn;
  final String publisher;
  final int quantity;
  final int availableQuantity;
  final String rack;

  const Book({
    required this.id,
    this.categoryId,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publisher,
    required this.quantity,
    required this.availableQuantity,
    required this.rack,
  });

  String get availabilityLabel => '$availableQuantity/$quantity';

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as int,
        categoryId: json['category'] as int?,
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        isbn: json['isbn'] as String? ?? '',
        publisher: json['publisher'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 0,
        availableQuantity: json['available_quantity'] as int? ?? 0,
        rack: json['rack'] as String? ?? '',
      );
}

// ── Library Student (simple reference) ───────────────────────────────────────

class LibraryStudent {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;

  const LibraryStudent({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayLabel => '$fullName ($admissionNo)';

  factory LibraryStudent.fromJson(Map<String, dynamic> json) => LibraryStudent(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
      );
}

// ── Library Staff (simple reference) ─────────────────────────────────────────

class LibraryStaff {
  final int id;
  final String staffNo;
  final String firstName;
  final String lastName;

  const LibraryStaff({
    required this.id,
    required this.staffNo,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayLabel => '$fullName (${staffNo.isNotEmpty ? staffNo : '-'})';

  factory LibraryStaff.fromJson(Map<String, dynamic> json) => LibraryStaff(
        id: json['id'] as int,
        staffNo: json['staff_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
      );
}

// ── Library Member ────────────────────────────────────────────────────────────

class LibraryMember {
  final int id;
  final String memberType; // 'student' | 'staff'
  final int? studentId;
  final int? staffId;
  final String cardNo;
  final bool isActive;
  // Embedded names — populated when the API returns nested objects
  final String? embeddedStudentName;
  final String? embeddedStaffName;

  const LibraryMember({
    required this.id,
    required this.memberType,
    this.studentId,
    this.staffId,
    required this.cardNo,
    required this.isActive,
    this.embeddedStudentName,
    this.embeddedStaffName,
  });

  bool get isStudent => memberType == 'student';

  factory LibraryMember.fromJson(Map<String, dynamic> json) {
    int? studentId;
    String? embeddedStudentName;
    int? staffId;
    String? embeddedStaffName;

    final studentData = json['student'];
    if (studentData is int) {
      studentId = studentData;
    } else if (studentData is Map<String, dynamic>) {
      studentId = studentData['id'] as int?;
      final fn = studentData['first_name'] as String? ?? '';
      final ln = studentData['last_name'] as String? ?? '';
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) embeddedStudentName = full;
    }

    final staffData = json['staff'];
    if (staffData is int) {
      staffId = staffData;
    } else if (staffData is Map<String, dynamic>) {
      staffId = staffData['id'] as int?;
      final fn = staffData['first_name'] as String? ?? '';
      final ln = staffData['last_name'] as String? ?? '';
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) embeddedStaffName = full;
    }

    return LibraryMember(
      id: json['id'] as int,
      memberType: json['member_type'] as String? ?? 'student',
      studentId: studentId,
      staffId: staffId,
      cardNo: json['card_no'] as String? ?? '',
      isActive: json['is_active'] == true,
      embeddedStudentName: embeddedStudentName,
      embeddedStaffName: embeddedStaffName,
    );
  }
}

// ── Book Issue ────────────────────────────────────────────────────────────────

class BookIssue {
  final int id;
  final int bookId;
  final int memberId;
  final String issueDate;
  final String dueDate;
  final String? returnDate;
  final String fineAmount;
  final String status; // 'issued' | 'returned' | 'lost'

  const BookIssue({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.issueDate,
    required this.dueDate,
    this.returnDate,
    required this.fineAmount,
    required this.status,
  });

  bool get isOverdue {
    if (status != 'issued') return false;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  factory BookIssue.fromJson(Map<String, dynamic> json) => BookIssue(
        id: json['id'] as int,
        bookId: json['book'] as int? ?? 0,
        memberId: json['member'] as int? ?? 0,
        issueDate: json['issue_date'] as String? ?? '',
        dueDate: json['due_date'] as String? ?? '',
        returnDate: json['return_date'] as String?,
        fineAmount: (json['fine_amount'] ?? '0.00').toString(),
        status: json['status'] as String? ?? 'issued',
      );
}
