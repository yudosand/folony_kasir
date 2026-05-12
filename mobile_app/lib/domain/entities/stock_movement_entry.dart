class StockMovementEntry {
  const StockMovementEntry({
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
}
