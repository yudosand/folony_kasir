import '../../domain/entities/stock_card.dart';
import 'product_dto.dart';
import 'stock_movement_entry_dto.dart';

class StockCardDto {
  const StockCardDto({
    required this.product,
    required this.initialStock,
    required this.stockAtPeriodStart,
    required this.stockIn,
    required this.stockOut,
    required this.movementCount,
    required this.movements,
  });

  final ProductDto product;
  final int initialStock;
  final int stockAtPeriodStart;
  final int stockIn;
  final int stockOut;
  final int movementCount;
  final List<StockMovementEntryDto> movements;

  factory StockCardDto.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>? ?? const {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? const {};
    final rawMovements = json['movements'] as List<dynamic>? ?? const [];

    return StockCardDto(
      product: ProductDto.fromJson(productJson),
      initialStock: (summaryJson['initial_stock'] as num?)?.toInt() ?? 0,
      stockAtPeriodStart:
          (summaryJson['stock_at_period_start'] as num?)?.toInt() ?? 0,
      stockIn: (summaryJson['stock_in'] as num?)?.toInt() ?? 0,
      stockOut: (summaryJson['stock_out'] as num?)?.toInt() ?? 0,
      movementCount: (summaryJson['movement_count'] as num?)?.toInt() ?? 0,
      movements: rawMovements
          .whereType<Map<String, dynamic>>()
          .map(StockMovementEntryDto.fromJson)
          .toList(),
    );
  }

  StockCard toEntity() {
    return StockCard(
      product: product.toEntity(),
      initialStock: initialStock,
      stockAtPeriodStart: stockAtPeriodStart,
      stockIn: stockIn,
      stockOut: stockOut,
      movementCount: movementCount,
      movements: movements.map((movement) => movement.toEntity()).toList(),
    );
  }
}
