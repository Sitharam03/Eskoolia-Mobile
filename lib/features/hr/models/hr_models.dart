// ── Department ────────────────────────────────────────────────────────────────

class Department {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> j) => Department(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        isActive: j['is_active'] == true,
      );
}

// ── Designation ───────────────────────────────────────────────────────────────

class Designation {
  final int id;
  final int? departmentId;
  final String departmentName;
  final String name;
  final bool isActive;

  const Designation({
    required this.id,
    this.departmentId,
    required this.departmentName,
    required this.name,
    required this.isActive,
  });

  factory Designation.fromJson(Map<String, dynamic> j) {
    int? deptId;
    String deptName = '';
    final d = j['department'];
    if (d is int) {
      deptId = d;
      deptName = j['department_name'] as String? ?? '';
    } else if (d is Map<String, dynamic>) {
      deptId = d['id'] as int?;
      deptName = d['name'] as String? ?? '';
    }
    if (deptName.isEmpty) deptName = j['department_name'] as String? ?? '';
    return Designation(
      id: j['id'] as int,
      departmentId: deptId,
      departmentName: deptName,
      name: j['name'] as String? ?? '',
      isActive: j['is_active'] == true,
    );
  }
}

// ── Staff ─────────────────────────────────────────────────────────────────────

class Staff {
  final int id;
  final String staffNo;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;
  final String fathersName;
  final String mothersName;
  final String emergencyMobile;
  final String drivingLicense;
  final String currentAddress;
  final String permanentAddress;
  final String qualification;
  final String experience;
  final String joinDate;
  final String basicSalary;
  final String contractType;
  final String location;
  final String epfNo;
  final String bankAccountName;
  final String bankAccountNo;
  final String bankName;
  final String bankBranch;
  final String facebookUrl;
  final String twitterUrl;
  final String linkedinUrl;
  final String instagramUrl;
  final String staffPhoto;
  final String resume;
  final String joiningLetter;
  final String otherDocument;
  final double casualLeave;
  final double medicalLeave;
  final double maternityLeave;
  final bool showPublic;
  final String status;
  final int? departmentId;
  final String departmentName;
  final int? designationId;
  final String designationName;
  final int? roleId;
  final String roleName;

  const Staff({
    required this.id,
    required this.staffNo,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.fathersName,
    required this.mothersName,
    required this.emergencyMobile,
    required this.drivingLicense,
    required this.currentAddress,
    required this.permanentAddress,
    required this.qualification,
    required this.experience,
    required this.joinDate,
    required this.basicSalary,
    required this.contractType,
    required this.location,
    required this.epfNo,
    required this.bankAccountName,
    required this.bankAccountNo,
    required this.bankName,
    required this.bankBranch,
    required this.facebookUrl,
    required this.twitterUrl,
    required this.linkedinUrl,
    required this.instagramUrl,
    required this.staffPhoto,
    required this.resume,
    required this.joiningLetter,
    required this.otherDocument,
    required this.casualLeave,
    required this.medicalLeave,
    required this.maternityLeave,
    required this.showPublic,
    required this.status,
    this.departmentId,
    required this.departmentName,
    this.designationId,
    required this.designationName,
    this.roleId,
    required this.roleName,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l'.isEmpty ? '?' : '$f$l';
  }

  factory Staff.fromJson(Map<String, dynamic> j) {
    int? deptId;
    String deptName = '';
    final d = j['department'];
    if (d is int) { deptId = d; deptName = j['department_name'] as String? ?? ''; }
    else if (d is Map<String, dynamic>) { deptId = d['id'] as int?; deptName = d['name'] as String? ?? ''; }
    if (deptName.isEmpty) deptName = j['department_name'] as String? ?? '';

    int? desigId;
    String desigName = '';
    final des = j['designation'];
    if (des is int) { desigId = des; desigName = j['designation_name'] as String? ?? ''; }
    else if (des is Map<String, dynamic>) { desigId = des['id'] as int?; desigName = des['name'] as String? ?? ''; }
    if (desigName.isEmpty) desigName = j['designation_name'] as String? ?? '';

    int? roleId;
    String roleName = '';
    final r = j['role'];
    if (r is int) { roleId = r; roleName = j['role_name'] as String? ?? ''; }
    else if (r is Map<String, dynamic>) { roleId = r['id'] as int?; roleName = r['name'] as String? ?? ''; }
    if (roleName.isEmpty) roleName = j['role_name'] as String? ?? '';

    return Staff(
      id: j['id'] as int,
      staffNo: j['staff_no'] as String? ?? '',
      firstName: j['first_name'] as String? ?? '',
      lastName: j['last_name'] as String? ?? '',
      email: j['email'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      gender: j['gender'] as String? ?? '',
      maritalStatus: j['marital_status'] as String? ?? '',
      dateOfBirth: j['date_of_birth'] as String? ?? '',
      fathersName: j['fathers_name'] as String? ?? '',
      mothersName: j['mothers_name'] as String? ?? '',
      emergencyMobile: j['emergency_mobile'] as String? ?? '',
      drivingLicense: j['driving_license'] as String? ?? '',
      currentAddress: j['current_address'] as String? ?? '',
      permanentAddress: j['permanent_address'] as String? ?? '',
      qualification: j['qualification'] as String? ?? '',
      experience: j['experience'] as String? ?? '',
      joinDate: j['join_date'] as String? ?? '',
      basicSalary: j['basic_salary']?.toString() ?? '0.00',
      contractType: j['contract_type'] as String? ?? '',
      location: j['location'] as String? ?? '',
      epfNo: j['epf_no'] as String? ?? '',
      bankAccountName: j['bank_account_name'] as String? ?? '',
      bankAccountNo: j['bank_account_no'] as String? ?? '',
      bankName: j['bank_name'] as String? ?? '',
      bankBranch: j['bank_branch'] as String? ?? '',
      facebookUrl: j['facebook_url'] as String? ?? '',
      twitterUrl: j['twitter_url'] as String? ?? '',
      linkedinUrl: j['linkedin_url'] as String? ?? '',
      instagramUrl: j['instagram_url'] as String? ?? '',
      staffPhoto: j['staff_photo'] as String? ?? '',
      resume: j['resume'] as String? ?? '',
      joiningLetter: j['joining_letter'] as String? ?? '',
      otherDocument: j['other_document'] as String? ?? '',
      casualLeave: _toDouble(j['casual_leave']),
      medicalLeave: _toDouble(j['medical_leave']),
      maternityLeave: _toDouble(j['maternity_leave']),
      showPublic: j['show_public'] == true,
      status: j['status'] as String? ?? 'active',
      departmentId: deptId,
      departmentName: deptName,
      designationId: desigId,
      designationName: desigName,
      roleId: roleId,
      roleName: roleName,
    );
  }
}

// ── Role (for dropdowns) ──────────────────────────────────────────────────────

class HrRole {
  final int id;
  final String name;

  const HrRole({required this.id, required this.name});

  factory HrRole.fromJson(Map<String, dynamic> j) => HrRole(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
      );
}

// ── Leave Type ────────────────────────────────────────────────────────────────

class LeaveType {
  final int id;
  final String name;
  final int maxDaysPerYear;
  final bool isPaid;
  final bool isActive;

  const LeaveType({
    required this.id,
    required this.name,
    required this.maxDaysPerYear,
    required this.isPaid,
    required this.isActive,
  });

  factory LeaveType.fromJson(Map<String, dynamic> j) => LeaveType(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        maxDaysPerYear: j['max_days_per_year'] as int? ?? 0,
        isPaid: j['is_paid'] == true,
        isActive: j['is_active'] == true,
      );
}

// ── Leave Define ──────────────────────────────────────────────────────────────

class LeaveDefine {
  final int id;
  final int? roleId;
  final String roleName;
  final int? staffId;
  final String staffName;
  final int? leaveTypeId;
  final String leaveTypeName;
  final int days;

  const LeaveDefine({
    required this.id,
    this.roleId,
    required this.roleName,
    this.staffId,
    required this.staffName,
    this.leaveTypeId,
    required this.leaveTypeName,
    required this.days,
  });

  factory LeaveDefine.fromJson(Map<String, dynamic> j) {
    int? roleId;
    String roleName = '';
    final r = j['role'];
    if (r is int) { roleId = r; roleName = j['role_name'] as String? ?? ''; }
    else if (r is Map<String, dynamic>) { roleId = r['id'] as int?; roleName = r['name'] as String? ?? ''; }
    if (roleName.isEmpty) roleName = j['role_name'] as String? ?? '';

    int? staffId;
    String staffName = '';
    final s = j['staff'];
    if (s is int) { staffId = s; staffName = j['staff_name'] as String? ?? ''; }
    else if (s is Map<String, dynamic>) { staffId = s['id'] as int?; staffName = s['first_name'] != null ? '${s['first_name']} ${s['last_name'] ?? ''}'.trim() : (s['name'] as String? ?? ''); }
    if (staffName.isEmpty) staffName = j['staff_name'] as String? ?? '';

    int? leaveTypeId;
    String leaveTypeName = '';
    final lt = j['leave_type'];
    if (lt is int) { leaveTypeId = lt; leaveTypeName = j['leave_type_name'] as String? ?? ''; }
    else if (lt is Map<String, dynamic>) { leaveTypeId = lt['id'] as int?; leaveTypeName = lt['name'] as String? ?? ''; }
    if (leaveTypeName.isEmpty) leaveTypeName = j['leave_type_name'] as String? ?? '';

    return LeaveDefine(
      id: j['id'] as int,
      roleId: roleId, roleName: roleName,
      staffId: staffId, staffName: staffName,
      leaveTypeId: leaveTypeId, leaveTypeName: leaveTypeName,
      days: j['days'] as int? ?? 0,
    );
  }
}

// ── Leave Request ─────────────────────────────────────────────────────────────

class LeaveRequest {
  final int id;
  final int? staffId;
  final String staffName;
  final int? leaveTypeId;
  final String leaveTypeName;
  final String fromDate;
  final String toDate;
  final String reason;
  final String approvalNote;
  final String status; // pending | approved | rejected
  final String createdAt;

  const LeaveRequest({
    required this.id,
    this.staffId,
    required this.staffName,
    this.leaveTypeId,
    required this.leaveTypeName,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.approvalNote,
    required this.status,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default: return 'Pending';
    }
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> j) {
    int? staffId;
    String staffName = '';
    final s = j['staff'];
    if (s is int) { staffId = s; staffName = j['staff_name'] as String? ?? ''; }
    else if (s is Map<String, dynamic>) { staffId = s['id'] as int?; staffName = '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim(); }
    if (staffName.isEmpty) staffName = j['staff_name'] as String? ?? '';

    int? ltId;
    String ltName = '';
    final lt = j['leave_type'];
    if (lt is int) { ltId = lt; ltName = j['leave_type_name'] as String? ?? ''; }
    else if (lt is Map<String, dynamic>) { ltId = lt['id'] as int?; ltName = lt['name'] as String? ?? ''; }
    if (ltName.isEmpty) ltName = j['leave_type_name'] as String? ?? '';

    return LeaveRequest(
      id: j['id'] as int,
      staffId: staffId, staffName: staffName,
      leaveTypeId: ltId, leaveTypeName: ltName,
      fromDate: j['from_date'] as String? ?? '',
      toDate: j['to_date'] as String? ?? '',
      reason: j['reason'] as String? ?? '',
      approvalNote: j['approval_note'] as String? ?? '',
      status: j['status'] as String? ?? 'pending',
      createdAt: j['created_at'] as String? ?? '',
    );
  }
}

// ── Staff Attendance ──────────────────────────────────────────────────────────

class StaffAttendance {
  final int id;
  final int? staffId;
  final String staffName;
  final String attendanceDate;
  final String attendanceType; // P | A | L | F | H
  final String note;

  const StaffAttendance({
    required this.id,
    this.staffId,
    required this.staffName,
    required this.attendanceDate,
    required this.attendanceType,
    required this.note,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> j) {
    int? staffId;
    String staffName = '';
    final s = j['staff'];
    if (s is int) { staffId = s; staffName = j['staff_name'] as String? ?? ''; }
    else if (s is Map<String, dynamic>) { staffId = s['id'] as int?; staffName = '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim(); }
    if (staffName.isEmpty) staffName = j['staff_name'] as String? ?? '';
    return StaffAttendance(
      id: j['id'] as int,
      staffId: staffId,
      staffName: staffName,
      attendanceDate: j['attendance_date'] as String? ?? '',
      attendanceType: j['attendance_type'] as String? ?? 'P',
      note: j['note'] as String? ?? '',
    );
  }
}

// ── Payroll ───────────────────────────────────────────────────────────────────

class PayrollRecord {
  final int id;
  final int? staffId;
  final String staffName;
  final int payrollMonth;
  final int payrollYear;
  final double basicSalary;
  final double allowance;
  final double deduction;
  final double netSalary;
  final String status; // draft | processed | paid
  final String? paidAt;

  const PayrollRecord({
    required this.id,
    this.staffId,
    required this.staffName,
    required this.payrollMonth,
    required this.payrollYear,
    required this.basicSalary,
    required this.allowance,
    required this.deduction,
    required this.netSalary,
    required this.status,
    this.paidAt,
  });

  String get monthName {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final idx = payrollMonth - 1;
    return (idx >= 0 && idx < 12) ? months[idx] : '$payrollMonth';
  }

  PayrollRecord copyWith({String? staffName}) => PayrollRecord(
    id: id,
    staffId: staffId,
    staffName: staffName ?? this.staffName,
    payrollMonth: payrollMonth,
    payrollYear: payrollYear,
    basicSalary: basicSalary,
    allowance: allowance,
    deduction: deduction,
    netSalary: netSalary,
    status: status,
    paidAt: paidAt,
  );

  factory PayrollRecord.fromJson(Map<String, dynamic> j) {
    int? staffId;
    String staffName = '';
    final s = j['staff'];
    if (s is int) {
      staffId = s;
      staffName = j['staff_name'] as String? ??
                  j['staff_full_name'] as String? ?? '';
    } else if (s is Map<String, dynamic>) {
      staffId = s['id'] as int?;
      final fn = s['first_name'] as String? ?? '';
      final ln = s['last_name'] as String? ?? '';
      staffName = '$fn $ln'.trim();
      if (staffName.isEmpty) {
        staffName = s['full_name'] as String? ?? s['name'] as String? ?? '';
      }
    }
    if (staffName.isEmpty) {
      staffName = j['staff_name'] as String? ??
                  j['staff_full_name'] as String? ?? '';
    }
    return PayrollRecord(
      id: j['id'] as int,
      staffId: staffId,
      staffName: staffName,
      payrollMonth: j['payroll_month'] as int? ?? 1,
      payrollYear: j['payroll_year'] as int? ?? DateTime.now().year,
      basicSalary: _toDouble(j['basic_salary']),
      allowance: _toDouble(j['allowance']),
      deduction: _toDouble(j['deduction']),
      netSalary: _toDouble(j['net_salary']),
      status: j['status'] as String? ?? 'draft',
      paidAt: j['paid_at'] as String?,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
