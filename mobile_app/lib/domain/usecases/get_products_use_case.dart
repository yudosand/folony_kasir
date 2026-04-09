import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call({
    String? search,
    int perPage = 100,
  }) {
    return _repository.getProducts(
      search: search,
      perPage: perPage,
    );
  }
}
