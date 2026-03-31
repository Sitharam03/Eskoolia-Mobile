class FeesPayment {
  final int id;
  final int assignment;
  final int student;
  final String studentName;
  final String admissionNo;
  final String feesTypeName;
  final double amountPaid;
  final String method;
  final String transactionReference;
  final String note;
  final String paidAt;
  final String? recordedBy;
  final String createdAt;

  const FeesPayment({
    required this.id,
    required this.assignment,
    required this.student,
    required this.studentName,
    required this.admissionNo,
    required this.feesTypeName,
    required this.amountPaid,
    required this.method,
    required this.transactionReference,
    required this.note,
    required this.paidAt,
    this.recordedBy,
    required this.createdAt,
  });

  factory FeesPayment.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) {
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt() ?? 0;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return FeesPayment(
      id: _id(j['id']),
      assignment: _id(j['assignment']),
      student: _id(j['student']),
      studentName: j['student_name']?.toString() ?? '',
      admissionNo: j['admission_no']?.toString() ?? '',
      feesTypeName: j['fees_type_name']?.toString() ?? '',
      amountPaid:
          double.tryParse(j['amount_paid']?.toString() ?? '0') ?? 0.0,
      method: j['method']?.toString() ?? 'cash',
      transactionReference:
          j['transaction_reference']?.toString() ?? '',
      note: j['note']?.toString() ?? '',
      paidAt: j['paid_at']?.toString() ?? '',
      recordedBy: j['recorded_by']?.toString(),
      createdAt: j['created_at']?.toString() ?? '',
    );
  }
}

// ── Receipt ────────────────────────────────────────────────────────────────────

class FeesReceipt {
  final int paymentId;
  final String transactionReference;
  final String method;
  final String paidAt;
  final double amountPaid;
  final String studentName;
  final String admissionNo;
  final String feesTypeName;
  final String dueDate;
  final double amount;
  final double discountAmount;
  final double netAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String? recordedBy;
  final String note;

  const FeesReceipt({
    required this.paymentId,
    required this.transactionReference,
    required this.method,
    required this.paidAt,
    required this.amountPaid,
    required this.studentName,
    required this.admissionNo,
    required this.feesTypeName,
    required this.dueDate,
    required this.amount,
    required this.discountAmount,
    required this.netAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.recordedBy,
    required this.note,
  });

  factory FeesReceipt.fromJson(Map<String, dynamic> j) {
    // student and assignment may be nested objects or plain maps
    final student = (j['student'] is Map)
        ? j['student'] as Map<String, dynamic>
        : <String, dynamic>{};
    final assignment = (j['assignment'] is Map)
        ? j['assignment'] as Map<String, dynamic>
        : <String, dynamic>{};

    // fees_type inside assignment can be a nested object, int ID, or string name
    String feesTypeName = '';
    final ft = assignment['fees_type'];
    if (ft is Map) {
      feesTypeName = ft['name']?.toString() ?? '';
    } else if (ft != null) {
      feesTypeName = ft.toString();
    }

    return FeesReceipt(
      paymentId: (j['payment_id'] as num?)?.toInt() ?? 0,
      transactionReference:
          j['transaction_reference']?.toString() ?? '',
      method: j['method']?.toString() ?? 'cash',
      paidAt: j['paid_at']?.toString() ?? '',
      amountPaid:
          double.tryParse(j['amount_paid']?.toString() ?? '0') ?? 0.0,
      studentName: student['name']?.toString() ??
          '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}'
              .trim(),
      admissionNo: student['admission_no']?.toString() ?? '',
      feesTypeName: feesTypeName,
      dueDate: assignment['due_date']?.toString() ?? '',
      amount:
          double.tryParse(assignment['amount']?.toString() ?? '0') ??
              0.0,
      discountAmount: double.tryParse(
              assignment['discount_amount']?.toString() ?? '0') ??
          0.0,
      netAmount: double.tryParse(
              assignment['net_amount']?.toString() ?? '0') ??
          0.0,
      paidAmount: double.tryParse(
              assignment['paid_amount']?.toString() ?? '0') ??
          0.0,
      dueAmount: double.tryParse(
              assignment['due_amount']?.toString() ?? '0') ??
          0.0,
      status: assignment['status']?.toString() ?? 'unpaid',
      recordedBy: j['recorded_by']?.toString(),
      note: j['note']?.toString() ?? '',
    );
  }
}
