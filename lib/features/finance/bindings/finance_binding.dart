import 'package:get/get.dart';

import '../controllers/bank_account_controller.dart';
import '../controllers/chart_of_accounts_controller.dart';
import '../controllers/fund_transfer_controller.dart';
import '../controllers/ledger_entry_controller.dart';
import '../repositories/finance_repository.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceRepository>(() => FinanceRepository(), fenix: true);

    Get.lazyPut<ChartOfAccountsController>(
      () => ChartOfAccountsController(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<BankAccountController>(
      () => BankAccountController(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<LedgerEntryController>(
      () => LedgerEntryController(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<FundTransferController>(
      () => FundTransferController(Get.find<FinanceRepository>()),
      fenix: true,
    );
  }
}
