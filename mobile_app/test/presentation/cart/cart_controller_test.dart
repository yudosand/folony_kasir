import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/domain/entities/product.dart';
import 'package:folony_kasir_mobile/presentation/cart/controllers/cart_controller.dart';

void main() {
  group('CartController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('does not decrement below quantity 1', () {
      final notifier = container.read(cartControllerProvider.notifier);
      notifier.addProduct(_product(stock: 5));

      notifier.decrementItem(1);

      final state = container.read(cartControllerProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.quantity, 1);
    });

    test('does not increment above available stock', () {
      final notifier = container.read(cartControllerProvider.notifier);
      notifier.addProduct(_product(stock: 2));
      notifier.incrementItem(1);
      notifier.incrementItem(1);

      final state = container.read(cartControllerProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.quantity, 2);
    });
  });
}

Product _product({required int stock}) {
  return Product(
    id: 1,
    name: 'Teh Botol',
    stock: stock,
    costPrice: 3000,
    sellingPrice: 5000,
  );
}
