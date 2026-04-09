import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  const CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
  }) {
    return _repository.createProduct(
      name: name,
      stock: stock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      imageFilePath: imageFilePath,
    );
  }
}
