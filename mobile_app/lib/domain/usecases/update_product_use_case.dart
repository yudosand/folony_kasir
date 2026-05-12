import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call({
    required int productId,
    required String name,
    required int stock,
    required int minimumStock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
    required bool removeImage,
  }) {
    return _repository.updateProduct(
      productId: productId,
      name: name,
      stock: stock,
      minimumStock: minimumStock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      imageFilePath: imageFilePath,
      removeImage: removeImage,
    );
  }
}
