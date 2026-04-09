class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.stock,
    required this.quantity,
    this.imageUrl,
  });

  final int productId;
  final String productName;
  final double sellingPrice;
  final int stock;
  final int quantity;
  final String? imageUrl;

  double get lineTotal => sellingPrice * quantity;

  CartItem copyWith({
    String? productName,
    double? sellingPrice,
    int? stock,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId,
      productName: productName ?? this.productName,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
