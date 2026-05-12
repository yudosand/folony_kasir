import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/stock_card.dart';

final stockCardControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<StockCardController, StockCard, int>(
  StockCardController.new,
);

class StockCardController extends AutoDisposeFamilyAsyncNotifier<StockCard, int> {
  String? _dateFrom;
  String? _dateTo;

  @override
  Future<StockCard> build(int arg) {
    return _fetch(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> setDateRange({
    String? dateFrom,
    String? dateTo,
  }) async {
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    await refresh();
  }

  Future<void> restock({
    required int quantity,
    double? unitCost,
    String? notes,
  }) async {
    final card = await ref.read(restockProductUseCaseProvider).call(
          productId: arg,
          quantity: quantity,
          unitCost: unitCost,
          notes: notes,
        );
    state = AsyncData(card);
  }

  Future<void> adjust({
    required String direction,
    required int quantity,
    String? notes,
  }) async {
    final card = await ref.read(adjustProductStockUseCaseProvider).call(
          productId: arg,
          direction: direction,
          quantity: quantity,
          notes: notes,
        );
    state = AsyncData(card);
  }

  Future<StockCard> _fetch(int productId) {
    return ref.read(getStockCardUseCaseProvider).call(
          productId,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
        );
  }
}
