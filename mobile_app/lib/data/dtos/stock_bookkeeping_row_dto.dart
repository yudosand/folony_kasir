import '../../domain/entities/stock_bookkeeping_row.dart';

class StockBookkeepingRowDto {
  const StockBookkeepingRowDto({
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

  factory StockBookkeepingRowDto.fromJson(Map<String, dynamic> json) {
    return StockBookkeepingRowDto(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? '',
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      minimumStock: (json['minimum_stock'] as num?)?.toInt() ?? 0,
      initialStock: (json['initial_stock'] as num?)?.toInt() ?? 0,
      stockAtPeriodStart:
          (json['stock_at_period_start'] as num?)?.toInt() ?? 0,
      stockIn: (json['stock_in'] as num?)?.toInt() ?? 0,
      stockOut: (json['stock_out'] as num?)?.toInt() ?? 0,
      movementCount: (json['movement_count'] as num?)?.toInt() ?? 0,
      stockStatus: json['stock_status'] as String? ?? 'healthy',
      stockStatusLabel: json['stock_status_label'] as String? ?? 'Aman',
      needsRestock: json['needs_restock'] as bool? ?? false,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
    );
  }

  StockBookkeepingRow toEntity() {
    return StockBookkeepingRow(
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      minimumStock: minimumStock,
      initialStock: initialStock,
      stockAtPeriodStart: stockAtPeriodStart,
      stockIn: stockIn,
      stockOut: stockOut,
      movementCount: movementCount,
      stockStatus: stockStatus,
      stockStatusLabel: stockStatusLabel,
      needsRestock: needsRestock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
