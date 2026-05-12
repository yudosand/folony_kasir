import '../entities/stock_bookkeeping_report.dart';
import '../repositories/stock_bookkeeping_repository.dart';

class GetStockBookkeepingReportUseCase {
  const GetStockBookkeepingReportUseCase(this._repository);

  final StockBookkeepingRepository _repository;

  Future<StockBookkeepingReport> call({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.getReport(
      search: search,
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
