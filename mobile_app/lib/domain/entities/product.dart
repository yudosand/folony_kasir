class Product {
  const Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.costPrice,
    required this.sellingPrice,
    this.imagePath,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final int stock;
  final double costPrice;
  final double sellingPrice;
  final String? imagePath;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
