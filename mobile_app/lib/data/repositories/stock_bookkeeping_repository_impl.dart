import '../../domain/entities/stock_bookkeeping_report.dart';
import '../../domain/entities/stock_card.dart';
import '../../domain/repositories/stock_bookkeeping_repository.dart';
import '../datasources/remote/stock_bookkeeping_remote_data_source.dart';

class StockBookkeepingRepositoryImpl implements StockBookkeepingRepository {
  StockBookkeepingRepositoryImpl(this._remoteDataSource);

  final StockBookkeepingRemoteDataSource _remoteDataSource;

  @override
  Future<StockBookkeepingReport> getReport({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _remoteDataSource.getReport(
      search: search,
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    return response.toEntity();
  }

  @override
  Future<StockCard> getStockCard(
    int productId, {
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _remoteDataSource.getStockCard(
      productId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    return response.toEntity();
  }

  @override
  Future<StockCard> restockProduct({
    required int productId,
    required int quantity,
    double? unitCost,
    String? notes,
  }) async {
    final response = await _remoteDataSource.restockProduct(
      productId: productId,
      quantity: quantity,
      unitCost: unitCost,
      notes: notes,
    );

    return response.toEntity();
  }

  @override
  Future<StockCard> adjustProduct({
    required int productId,
    required String direction,
    required int quantity,
    String? notes,
  }) async {
    final response = await _remoteDataSource.adjustProduct(
      productId: productId,
      direction: direction,
      quantity: quantity,
      notes: notes,
    );

    return response.toEntity();
  }
}
