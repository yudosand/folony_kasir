import '../entities/stock_bookkeeping_report.dart';
import '../entities/stock_card.dart';

abstract class StockBookkeepingRepository {
  Future<StockBookkeepingReport> getReport({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  });

  Future<StockCard> getStockCard(
    int productId, {
    String? dateFrom,
    String? dateTo,
  });

  Future<StockCard> restockProduct({
    required int productId,
    required int quantity,
    double? unitCost,
    String? notes,
  });

  Future<StockCard> adjustProduct({
    required int productId,
    required String direction,
    required int quantity,
    String? notes,
  });
}
