import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addProduct(Product product) {
    if (product.stock <= 0) {
      return;
    }

    final currentItems = [...state.items];
    final existingIndex = currentItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = currentItems[existingIndex];
      if (existingItem.quantity >= existingItem.stock) {
        return;
      }

      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
        stock: product.stock,
        sellingPrice: product.sellingPrice,
        imageUrl: product.imageUrl,
      );
    } else {
      currentItems.add(
        CartItem(
          productId: product.id,
          productName: product.name,
          sellingPrice: product.sellingPrice,
          stock: product.stock,
          quantity: 1,
          imageUrl: product.imageUrl,
        ),
      );
    }

    state = CartState(items: currentItems);
  }

  void incrementItem(int productId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.productId != productId || item.quantity >= item.stock) {
          return item;
        }

        return item.copyWith(quantity: item.quantity + 1);
      }).toList(),
    );
  }

  void decrementItem(int productId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.productId != productId || item.quantity <= 1) {
          return item;
        }

        return item.copyWith(quantity: item.quantity - 1);
      }).toList(),
    );
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.productId != productId).toList(),
    );
  }

  void clear() {
    state = const CartState();
  }
}

class CartState {
  const CartState({
    this.items = const [],
  });

  final List<CartItem> items;

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}
