import '../entities/stock_card.dart';
import '../repositories/stock_bookkeeping_repository.dart';

class AdjustProductStockUseCase {
  const AdjustProductStockUseCase(this._repository);

  final StockBookkeepingRepository _repository;

  Future<StockCard> call({
    required int productId,
    required String direction,
    required int quantity,
    String? notes,
  }) {
    return _repository.adjustProduct(
      productId: productId,
      direction: direction,
      quantity: quantity,
      notes: notes,
    );
  }
}
