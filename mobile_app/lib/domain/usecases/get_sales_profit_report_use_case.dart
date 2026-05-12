import '../entities/sales_profit_report.dart';
import '../repositories/sales_profit_repository.dart';

class GetSalesProfitReportUseCase {
  const GetSalesProfitReportUseCase(this._repository);

  final SalesProfitRepository _repository;

  Future<SalesProfitReport> call({
    String? search,
    String? paymentMethod,
    String? profitStatus,
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.getReport(
      search: search,
      paymentMethod: paymentMethod,
      profitStatus: profitStatus,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
