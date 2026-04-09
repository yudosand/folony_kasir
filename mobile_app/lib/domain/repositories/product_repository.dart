import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? search,
    int perPage = 100,
  });

  Future<Product> createProduct({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
  });

  Future<Product> updateProduct({
    required int productId,
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
    required bool removeImage,
  });

  Future<void> deleteProduct(int productId);
}
