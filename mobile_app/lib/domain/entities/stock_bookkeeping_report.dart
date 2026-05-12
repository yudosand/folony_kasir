import 'stock_bookkeeping_row.dart';

class StockBookkeepingReport {
  const StockBookkeepingReport({
    required this.productCount,
    required this.needsRestockCount,
    required this.outOfStockCount,
    required this.lowStockCount,
    required this.rows,
  });

  final int productCount;
  final int needsRestockCount;
  final int outOfStockCount;
  final int lowStockCount;
  final List<StockBookkeepingRow> rows;
}
