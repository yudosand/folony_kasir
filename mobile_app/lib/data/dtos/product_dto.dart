import '../../domain/entities/product.dart';
import '../../core/utils/media_url_resolver.dart';

class ProductDto {
  ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      imagePath: json['image_path'] as String?,
      imageUrl: MediaUrlResolver.resolve(json['image_url'] as String?),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      stock: stock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      imagePath: imagePath,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
