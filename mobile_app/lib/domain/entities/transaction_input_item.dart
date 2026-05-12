class TransactionInputItem {
  const TransactionInputItem({
    required this.name,
    required this.quantity,
    required this.costPrice,
    required this.unitPrice,
    this.id,
    this.productId,
    this.availableStock,
    this.imageUrl,
  });

  final String? id;
  final int? productId;
  final String name;
  final int quantity;
  final double costPrice;
  final double unitPrice;
  final int? availableStock;
  final String? imageUrl;

  bool get isManual => productId == null;

  double get lineSubtotal => quantity * unitPrice;

  TransactionInputItem copyWith({
    String? id,
    int? productId,
    String? name,
    int? quantity,
    double? costPrice,
    double? unitPrice,
    int? availableStock,
    String? imageUrl,
  }) {
    return TransactionInputItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      unitPrice: unitPrice ?? this.unitPrice,
      availableStock: availableStock ?? this.availableStock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
