class StockBookkeepingRow {
  const StockBookkeepingRow({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minimumStock,
    required this.initialStock,
    required this.stockAtPeriodStart,
    required this.stockIn,
    required this.stockOut,
    required this.movementCount,
    required this.stockStatus,
    required this.stockStatusLabel,
    required this.needsRestock,
    required this.costPrice,
    required this.sellingPrice,
    this.createdAt,
    this.updatedAt,
  });

  final int productId;
  final String productName;
  final int currentStock;
  final int minimumStock;
  final int initialStock;
  final int stockAtPeriodStart;
  final int stockIn;
  final int stockOut;
  final int movementCount;
  final String stockStatus;
  final String stockStatusLabel;
  final bool needsRestock;
  final double costPrice;
  final double sellingPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
