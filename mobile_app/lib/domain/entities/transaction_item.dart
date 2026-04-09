class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.productId,
    required this.isManual,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.lineSubtotal,
  });

  final int id;
  final int? productId;
  final bool isManual;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double lineSubtotal;
}
