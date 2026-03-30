class FeesAssignment {
  final int id;
  final int academicYear;
  final int student;
  final String studentName;
  final String admissionNo;
  final int feesType;
  final String feesTypeName;
  final String dueDate;
  final double amount;
  final double discountAmount;
  final String status; // 'unpaid' | 'partial' | 'paid'
  final double netAmount;
  final double paidAmount;
  final double dueAmount;
  final String createdAt;

  const FeesAssignment({
    required this.id,
    required this.academicYear,
    required this.student,
    required this.studentName,
    required this.admissionNo,
    required this.feesType,
    required this.feesTypeName,
    required this.dueDate,
    required this.amount,
    required this.discountAmount,
    required this.status,
    required this.netAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.createdAt,
  });

  factory FeesAssignment.fromJson(Map<String, dynamic> j) {
    // academic_year / student / fees_type may come back as int or nested object
    int _id(dynamic v) {
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt() ?? 0;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return FeesAssignment(
      id: _id(j['id']),
      academicYear: _id(j['academic_year']),
      student: _id(j['student']),
      studentName: j['student_name']?.toString() ?? '',
      admissionNo: j['admission_no']?.toString() ?? '',
      feesType: _id(j['fees_type']),
      feesTypeName: j['fees_type_name']?.toString() ?? '',
      dueDate: j['due_date']?.toString() ?? '',
      amount:
          double.tryParse(j['amount']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(
              j['discount_amount']?.toString() ?? '0') ??
          0.0,
      status: j['status']?.toString() ?? 'unpaid',
      netAmount:
          double.tryParse(j['net_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount:
          double.tryParse(j['paid_amount']?.toString() ?? '0') ?? 0.0,
      dueAmount:
          double.tryParse(j['due_amount']?.toString() ?? '0') ?? 0.0,
      createdAt: j['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'academic_year': academicYear,
        'student': student,
        'fees_type': feesType,
        'due_date': dueDate,
        'amount': amount.toString(),
        'discount_amount': discountAmount.toString(),
      };

  FeesAssignment copyWith({
    int? id,
    int? academicYear,
    int? student,
    String? studentName,
    String? admissionNo,
    int? feesType,
    String? feesTypeName,
    String? dueDate,
    double? amount,
    double? discountAmount,
    String? status,
    double? netAmount,
    double? paidAmount,
    double? dueAmount,
    String? createdAt,
  }) =>
      FeesAssignment(
        id: id ?? this.id,
        academicYear: academicYear ?? this.academicYear,
        student: student ?? this.student,
        studentName: studentName ?? this.studentName,
        admissionNo: admissionNo ?? this.admissionNo,
        feesType: feesType ?? this.feesType,
        feesTypeName: feesTypeName ?? this.feesTypeName,
        dueDate: dueDate ?? this.dueDate,
        amount: amount ?? this.amount,
        discountAmount: discountAmount ?? this.discountAmount,
        status: status ?? this.status,
        netAmount: netAmount ?? this.netAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        dueAmount: dueAmount ?? this.dueAmount,
        createdAt: createdAt ?? this.createdAt,
      );
}

// ── Summary ────────────────────────────────────────────────────────────────────

class FeesSummary {
  final int count;
  final double totalAssigned;
  final double totalDiscount;
  final double totalNet;
  final double totalPaid;
  final double totalDue;

  const FeesSummary({
    required this.count,
    required this.totalAssigned,
    required this.totalDiscount,
    required this.totalNet,
    required this.totalPaid,
    required this.totalDue,
  });

  factory FeesSummary.fromJson(Map<String, dynamic> j) => FeesSummary(
        count: (j['count'] as num?)?.toInt() ?? 0,
        totalAssigned:
            double.tryParse(j['total_assigned']?.toString() ?? '0') ??
                0.0,
        totalDiscount:
            double.tryParse(j['total_discount']?.toString() ?? '0') ??
                0.0,
        totalNet:
            double.tryParse(j['total_net']?.toString() ?? '0') ?? 0.0,
        totalPaid:
            double.tryParse(j['total_paid']?.toString() ?? '0') ?? 0.0,
        totalDue:
            double.tryParse(j['total_due']?.toString() ?? '0') ?? 0.0,
      );

  static const empty = FeesSummary(
    count: 0,
    totalAssigned: 0,
    totalDiscount: 0,
    totalNet: 0,
    totalPaid: 0,
    totalDue: 0,
  );
}

// ── Reference models ───────────────────────────────────────────────────────────

class AcademicYearRef {
  final int id;
  final String title;

  const AcademicYearRef({required this.id, required this.title});

  factory AcademicYearRef.fromJson(Map<String, dynamic> j) =>
      AcademicYearRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ??
            j['name']?.toString() ??
            '',
      );
}

class StudentRef {
  final int id;
  final String name;
  final String admissionNo;

  const StudentRef({
    required this.id,
    required this.name,
    required this.admissionNo,
  });

  factory StudentRef.fromJson(Map<String, dynamic> j) => StudentRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name:
            '${j['first_name']?.toString() ?? ''} ${j['last_name']?.toString() ?? ''}'
                .trim(),
        admissionNo: j['admission_no']?.toString() ?? '',
      );

  String get displayLabel =>
      admissionNo.isNotEmpty ? '$name ($admissionNo)' : name;
}
