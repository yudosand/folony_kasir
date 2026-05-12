import '../../domain/entities/stock_movement_entry.dart';

class StockMovementEntryDto {
  const StockMovementEntryDto({
    required this.id,
    required this.type,
    required this.direction,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.unitCostSnapshot,
    this.referenceType,
    this.referenceId,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String type;
  final String direction;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final double? unitCostSnapshot;
  final String? referenceType;
  final int? referenceId;
  final String? notes;
  final DateTime? createdAt;

  factory StockMovementEntryDto.fromJson(Map<String, dynamic> json) {
    return StockMovementEntryDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      direction: json['direction'] as String? ?? 'in',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stockBefore: (json['stock_before'] as num?)?.toInt() ?? 0,
      stockAfter: (json['stock_after'] as num?)?.toInt() ?? 0,
      unitCostSnapshot: (json['unit_cost_snapshot'] as num?)?.toDouble(),
      referenceType: json['reference_type'] as String?,
      referenceId: (json['reference_id'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  StockMovementEntry toEntity() {
    return StockMovementEntry(
      id: id,
      type: type,
      direction: direction,
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      unitCostSnapshot: unitCostSnapshot,
      referenceType: referenceType,
      referenceId: referenceId,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
