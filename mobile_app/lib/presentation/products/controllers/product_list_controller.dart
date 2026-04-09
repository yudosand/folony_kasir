import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/product.dart';

final productListControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProductListController, List<Product>>(
  ProductListController.new,
);

class ProductListController extends AutoDisposeAsyncNotifier<List<Product>> {
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  Future<List<Product>> build() async {
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return _fetchProducts();
  }

  Future<void> refreshProducts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProducts);
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      refreshProducts();
    });
  }

  Future<void> deleteProduct(int productId) async {
    await ref.read(deleteProductUseCaseProvider).call(productId);
    await refreshProducts();
  }

  Future<List<Product>> _fetchProducts() {
    return ref.read(getProductsUseCaseProvider).call(
          search: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }
}
