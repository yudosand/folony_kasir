class Product {
  const Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.minimumStock,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockStatus,
    required this.stockStatusLabel,
    required this.needsRestock,
    this.imagePath,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final int stock;
  final int minimumStock;
  final double costPrice;
  final double sellingPrice;
  final String stockStatus;
  final String stockStatusLabel;
  final bool needsRestock;
  final String? imagePath;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
