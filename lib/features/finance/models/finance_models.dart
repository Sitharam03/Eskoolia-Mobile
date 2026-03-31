// ─────────────────────────────────────────────────────────────────────────────
//  Finance Models
// ─────────────────────────────────────────────────────────────────────────────

class ChartOfAccount {
  final int id;
  final String code;
  final String name;
  final String accountType; // asset | liability | equity | income | expense
  final String description;
  final bool isActive;
  final String balance; // computed server-side (debit - credit)

  const ChartOfAccount({
    required this.id,
    required this.code,
    required this.name,
    required this.accountType,
    required this.description,
    required this.isActive,
    required this.balance,
  });

  factory ChartOfAccount.fromJson(Map<String, dynamic> j) => ChartOfAccount(
        id: (j['id'] as num?)?.toInt() ?? 0,
        code: j['code']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        accountType: j['account_type']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        isActive: j['is_active'] as bool? ?? true,
        balance: j['balance']?.toString() ?? '0.00',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'account_type': accountType,
        'description': description,
        'is_active': isActive,
      };

  ChartOfAccount copyWith({
    int? id,
    String? code,
    String? name,
    String? accountType,
    String? description,
    bool? isActive,
    String? balance,
  }) =>
      ChartOfAccount(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        accountType: accountType ?? this.accountType,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        balance: balance ?? this.balance,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class BankAccount {
  final int id;
  final String name;
  final String bankName;
  final String accountNumber;
  final String branch;
  final String currentBalance;
  final bool isActive;

  const BankAccount({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.branch,
    required this.currentBalance,
    required this.isActive,
  });

  factory BankAccount.fromJson(Map<String, dynamic> j) => BankAccount(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
        bankName: j['bank_name']?.toString() ?? '',
        accountNumber: j['account_number']?.toString() ?? '',
        branch: j['branch']?.toString() ?? '',
        currentBalance: j['current_balance']?.toString() ?? '0.00',
        isActive: j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'bank_name': bankName,
        'account_number': accountNumber,
        'branch': branch,
        'current_balance': currentBalance,
        'is_active': isActive,
      };

  BankAccount copyWith({
    int? id,
    String? name,
    String? bankName,
    String? accountNumber,
    String? branch,
    String? currentBalance,
    bool? isActive,
  }) =>
      BankAccount(
        id: id ?? this.id,
        name: name ?? this.name,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        branch: branch ?? this.branch,
        currentBalance: currentBalance ?? this.currentBalance,
        isActive: isActive ?? this.isActive,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class LedgerEntry {
  final int id;
  final int? academicYearId;
  final int accountId;
  final String entryType; // 'debit' | 'credit'
  final String amount;
  final String entryDate;
  final String referenceNo;
  final String description;

  const LedgerEntry({
    required this.id,
    this.academicYearId,
    required this.accountId,
    required this.entryType,
    required this.amount,
    required this.entryDate,
    required this.referenceNo,
    required this.description,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
        id: (j['id'] as num?)?.toInt() ?? 0,
        academicYearId: j['academic_year'] is num
            ? (j['academic_year'] as num).toInt()
            : null,
        accountId: j['account'] is num
            ? (j['account'] as num).toInt()
            : (j['account'] is Map
                ? ((j['account'] as Map)['id'] as num?)?.toInt() ?? 0
                : 0),
        entryType: j['entry_type']?.toString() ?? '',
        amount: j['amount']?.toString() ?? '0.00',
        entryDate: j['entry_date']?.toString() ?? '',
        referenceNo: j['reference_no']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'account': accountId,
      'entry_type': entryType,
      'amount': amount,
      'entry_date': entryDate,
      'reference_no': referenceNo,
      'description': description,
    };
    if (academicYearId != null) m['academic_year'] = academicYearId;
    return m;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class FundTransfer {
  final int id;
  final int fromBankId;
  final int toBankId;
  final String amount;
  final String transferDate;
  final String referenceNo;
  final String note;

  const FundTransfer({
    required this.id,
    required this.fromBankId,
    required this.toBankId,
    required this.amount,
    required this.transferDate,
    required this.referenceNo,
    required this.note,
  });

  factory FundTransfer.fromJson(Map<String, dynamic> j) => FundTransfer(
        id: (j['id'] as num?)?.toInt() ?? 0,
        fromBankId: j['from_bank'] is num
            ? (j['from_bank'] as num).toInt()
            : (j['from_bank'] is Map
                ? ((j['from_bank'] as Map)['id'] as num?)?.toInt() ?? 0
                : 0),
        toBankId: j['to_bank'] is num
            ? (j['to_bank'] as num).toInt()
            : (j['to_bank'] is Map
                ? ((j['to_bank'] as Map)['id'] as num?)?.toInt() ?? 0
                : 0),
        amount: j['amount']?.toString() ?? '0.00',
        transferDate: j['transfer_date']?.toString() ?? '',
        referenceNo: j['reference_no']?.toString() ?? '',
        note: j['note']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'from_bank': fromBankId,
        'to_bank': toBankId,
        'amount': amount,
        'transfer_date': transferDate,
        'reference_no': referenceNo,
        'note': note,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class LedgerSummary {
  final int count;
  final String totalDebit;
  final String totalCredit;
  final String netBalance;

  const LedgerSummary({
    required this.count,
    required this.totalDebit,
    required this.totalCredit,
    required this.netBalance,
  });

  factory LedgerSummary.fromJson(Map<String, dynamic> j) => LedgerSummary(
        count: (j['count'] as num?)?.toInt() ?? 0,
        totalDebit: j['total_debit']?.toString() ?? '0.00',
        totalCredit: j['total_credit']?.toString() ?? '0.00',
        netBalance: j['net_balance']?.toString() ?? '0.00',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class TrialBalanceRow {
  final int accountId;
  final String accountCode;
  final String accountName;
  final String accountType;
  final String debit;
  final String credit;
  final String balance;

  const TrialBalanceRow({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory TrialBalanceRow.fromJson(Map<String, dynamic> j) => TrialBalanceRow(
        accountId: (j['account_id'] as num?)?.toInt() ?? 0,
        accountCode: j['account_code']?.toString() ?? '',
        accountName: j['account_name']?.toString() ?? '',
        accountType: j['account_type']?.toString() ?? '',
        debit: j['debit']?.toString() ?? '0.00',
        credit: j['credit']?.toString() ?? '0.00',
        balance: j['balance']?.toString() ?? '0.00',
      );
}

class TrialBalance {
  final List<TrialBalanceRow> accounts;
  final String totalDebit;
  final String totalCredit;
  final String difference;

  const TrialBalance({
    required this.accounts,
    required this.totalDebit,
    required this.totalCredit,
    required this.difference,
  });

  factory TrialBalance.fromJson(Map<String, dynamic> j) => TrialBalance(
        accounts: ((j['accounts'] ?? []) as List)
            .map((e) => TrialBalanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalDebit: j['total_debit']?.toString() ?? '0.00',
        totalCredit: j['total_credit']?.toString() ?? '0.00',
        difference: j['difference']?.toString() ?? '0.00',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class BankStatement {
  final int bankAccountId;
  final String bankAccountName;
  final String incomingTotal;
  final String outgoingTotal;
  final String netMovement;
  final String currentBalance;

  const BankStatement({
    required this.bankAccountId,
    required this.bankAccountName,
    required this.incomingTotal,
    required this.outgoingTotal,
    required this.netMovement,
    required this.currentBalance,
  });

  factory BankStatement.fromJson(Map<String, dynamic> j) => BankStatement(
        bankAccountId: (j['bank_account_id'] as num?)?.toInt() ?? 0,
        bankAccountName: j['bank_account_name']?.toString() ?? '',
        incomingTotal: j['incoming_total']?.toString() ?? '0.00',
        outgoingTotal: j['outgoing_total']?.toString() ?? '0.00',
        netMovement: j['net_movement']?.toString() ?? '0.00',
        currentBalance: j['current_balance']?.toString() ?? '0.00',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class FinAcademicYear {
  final int id;
  final String title;

  const FinAcademicYear({required this.id, required this.title});

  factory FinAcademicYear.fromJson(Map<String, dynamic> j) => FinAcademicYear(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? j['name']?.toString() ?? '',
      );
}
