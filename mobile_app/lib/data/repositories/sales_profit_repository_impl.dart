import '../../domain/entities/sales_profit_report.dart';
import '../../domain/repositories/sales_profit_repository.dart';
import '../datasources/remote/sales_profit_remote_data_source.dart';

class SalesProfitRepositoryImpl implements SalesProfitRepository {
  SalesProfitRepositoryImpl(this._remoteDataSource);

  final SalesProfitRemoteDataSource _remoteDataSource;

  @override
  Future<SalesProfitReport> getReport({
    String? search,
    String? paymentMethod,
    String? profitStatus,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _remoteDataSource.getReport(
      search: search,
      paymentMethod: paymentMethod,
      profitStatus: profitStatus,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    return response.toEntity();
  }
}
