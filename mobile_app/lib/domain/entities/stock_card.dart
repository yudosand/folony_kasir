import 'product.dart';
import 'stock_movement_entry.dart';

class StockCard {
  const StockCard({
    required this.product,
    required this.initialStock,
    required this.stockAtPeriodStart,
    required this.stockIn,
    required this.stockOut,
    required this.movementCount,
    required this.movements,
  });

  final Product product;
  final int initialStock;
  final int stockAtPeriodStart;
  final int stockIn;
  final int stockOut;
  final int movementCount;
  final List<StockMovementEntry> movements;
}
