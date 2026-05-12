import '../entities/sales_profit_report.dart';

abstract class SalesProfitRepository {
  Future<SalesProfitReport> getReport({
    String? search,
    String? paymentMethod,
    String? profitStatus,
    String? dateFrom,
    String? dateTo,
  });
}
