import 'product_dto.dart';

class ProductListResponseDto {
  ProductListResponseDto({
    required this.products,
    required this.total,
  });

  final List<ProductDto> products;
  final int total;

  factory ProductListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? const [];
    final pagination = json['pagination'] as Map<String, dynamic>?;

    return ProductListResponseDto(
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(ProductDto.fromJson)
          .toList(),
      total: (pagination?['total'] as num?)?.toInt() ?? rawProducts.length,
    );
  }
}
