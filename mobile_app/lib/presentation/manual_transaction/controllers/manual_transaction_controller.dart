import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaction_input_item.dart';

final manualTransactionControllerProvider =
    NotifierProvider<ManualTransactionController, ManualTransactionState>(
  ManualTransactionController.new,
);

class ManualTransactionController extends Notifier<ManualTransactionState> {
  @override
  ManualTransactionState build() => const ManualTransactionState();

  bool addCatalogProduct(Product product) {
    if (product.stock <= 0) {
      return false;
    }

    final items = [...state.items];
    final itemId = _catalogItemId(product.id);
    final existingIndex = items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      final existingItem = items[existingIndex];
      final availableStock = existingItem.availableStock ?? product.stock;
      if (existingItem.quantity >= availableStock) {
        return false;
      }

      items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
        unitPrice: product.sellingPrice,
        availableStock: product.stock,
        imageUrl: product.imageUrl,
        name: product.name,
      );
    } else {
      items.add(
        TransactionInputItem(
          id: itemId,
          productId: product.id,
          name: product.name,
          quantity: 1,
          unitPrice: product.sellingPrice,
          availableStock: product.stock,
          imageUrl: product.imageUrl,
        ),
      );
    }

    state = ManualTransactionState(items: items);
    return true;
  }

  void addManualItem({
    required String name,
    required int quantity,
    required double unitPrice,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || quantity < 1 || unitPrice < 0) {
      return;
    }

    state = ManualTransactionState(
      items: [
        ...state.items,
        TransactionInputItem(
          id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
          name: trimmedName,
          quantity: quantity,
          unitPrice: unitPrice,
        ),
      ],
    );
  }

  bool incrementItem(String itemId) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.id == itemId);
    if (index < 0) {
      return false;
    }

    final item = items[index];
    if (!item.isManual) {
      final availableStock = item.availableStock ?? 0;
      if (item.quantity >= availableStock) {
        return false;
      }
    }

    items[index] = item.copyWith(quantity: item.quantity + 1);
    state = ManualTransactionState(items: items);
    return true;
  }

  void decrementItem(String itemId) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.id == itemId);
    if (index < 0) {
      return;
    }

    final item = items[index];
    if (item.quantity <= 1) {
      return;
    }

    items[index] = item.copyWith(quantity: item.quantity - 1);
    state = ManualTransactionState(items: items);
  }

  void removeItem(String itemId) {
    state = ManualTransactionState(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void clear() {
    state = const ManualTransactionState();
  }

  String _catalogItemId(int productId) => 'product-$productId';
}

class ManualTransactionState {
  const ManualTransactionState({
    this.items = const [],
  });

  final List<TransactionInputItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);
}
