import '../../../core/network/api_client.dart';
import '../models/finance_models.dart';

class FinanceRepository {
  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    List raw;
    if (data is Map) {
      raw = (data['results'] ?? data['data'] ?? []) as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = [];
    }
    return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Chart of Accounts ──────────────────────────────────────────────────────

  Future<List<ChartOfAccount>> getChartOfAccounts(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/finance/chart-of-accounts/',
        queryParameters: params);
    return _parseList(resp.data, ChartOfAccount.fromJson);
  }

  Future<ChartOfAccount> createChartOfAccount(
      Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .post('/api/v1/finance/chart-of-accounts/', data: data);
    return ChartOfAccount.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ChartOfAccount> updateChartOfAccount(
      int id, Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .patch('/api/v1/finance/chart-of-accounts/$id/', data: data);
    return ChartOfAccount.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteChartOfAccount(int id) async {
    await ApiClient.dio.delete('/api/v1/finance/chart-of-accounts/$id/');
  }

  // ── Bank Accounts ──────────────────────────────────────────────────────────

  Future<List<BankAccount>> getBankAccounts(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/finance/bank-accounts/', queryParameters: params);
    return _parseList(resp.data, BankAccount.fromJson);
  }

  Future<BankAccount> createBankAccount(Map<String, dynamic> data) async {
    final resp =
        await ApiClient.dio.post('/api/v1/finance/bank-accounts/', data: data);
    return BankAccount.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<BankAccount> updateBankAccount(
      int id, Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .patch('/api/v1/finance/bank-accounts/$id/', data: data);
    return BankAccount.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteBankAccount(int id) async {
    await ApiClient.dio.delete('/api/v1/finance/bank-accounts/$id/');
  }

  Future<BankStatement> getBankStatement(int id,
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/finance/bank-accounts/$id/statement/',
        queryParameters: params);
    return BankStatement.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Ledger Entries ─────────────────────────────────────────────────────────

  Future<List<LedgerEntry>> getLedgerEntries(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/finance/ledger-entries/', queryParameters: params);
    return _parseList(resp.data, LedgerEntry.fromJson);
  }

  Future<LedgerEntry> createLedgerEntry(Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .post('/api/v1/finance/ledger-entries/', data: data);
    return LedgerEntry.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteLedgerEntry(int id) async {
    await ApiClient.dio.delete('/api/v1/finance/ledger-entries/$id/');
  }

  Future<LedgerSummary> getLedgerSummary(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/finance/ledger-entries/summary/',
        queryParameters: params);
    return LedgerSummary.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<TrialBalance> getTrialBalance(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio.get(
        '/api/v1/finance/ledger-entries/trial-balance/',
        queryParameters: params);
    return TrialBalance.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Fund Transfers ─────────────────────────────────────────────────────────

  Future<List<FundTransfer>> getFundTransfers(
      {Map<String, dynamic>? params}) async {
    final resp = await ApiClient.dio
        .get('/api/v1/finance/fund-transfers/', queryParameters: params);
    return _parseList(resp.data, FundTransfer.fromJson);
  }

  Future<FundTransfer> createFundTransfer(Map<String, dynamic> data) async {
    final resp = await ApiClient.dio
        .post('/api/v1/finance/fund-transfers/', data: data);
    return FundTransfer.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteFundTransfer(int id) async {
    await ApiClient.dio.delete('/api/v1/finance/fund-transfers/$id/');
  }

  // ── Support ────────────────────────────────────────────────────────────────

  Future<List<FinAcademicYear>> getAcademicYears() async {
    final resp = await ApiClient.dio.get('/api/v1/core/academic-years/',
        queryParameters: {'page_size': 100});
    return _parseList(resp.data, FinAcademicYear.fromJson);
  }
}
