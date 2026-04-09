import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(int productId) {
    return _repository.deleteProduct(productId);
  }
}
