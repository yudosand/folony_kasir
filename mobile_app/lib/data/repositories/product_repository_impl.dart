import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts({
    String? search,
    int perPage = 100,
  }) async {
    final response = await _remoteDataSource.getProducts(
      search: search,
      perPage: perPage,
    );

    return response.products.map((product) => product.toEntity()).toList();
  }

  @override
  Future<Product> createProduct({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
  }) async {
    final response = await _remoteDataSource.createProduct(
      name: name,
      stock: stock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      imageFilePath: imageFilePath,
    );

    return response.toEntity();
  }

  @override
  Future<Product> updateProduct({
    required int productId,
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
    required bool removeImage,
  }) async {
    final response = await _remoteDataSource.updateProduct(
      productId: productId,
      name: name,
      stock: stock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      imageFilePath: imageFilePath,
      removeImage: removeImage,
    );

    return response.toEntity();
  }

  @override
  Future<void> deleteProduct(int productId) {
    return _remoteDataSource.deleteProduct(productId);
  }
}
