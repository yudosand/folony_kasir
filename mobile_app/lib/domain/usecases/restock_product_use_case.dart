import '../entities/stock_card.dart';
import '../repositories/stock_bookkeeping_repository.dart';

class RestockProductUseCase {
  const RestockProductUseCase(this._repository);

  final StockBookkeepingRepository _repository;

  Future<StockCard> call({
    required int productId,
    required int quantity,
    double? unitCost,
    String? notes,
  }) {
    return _repository.restockProduct(
      productId: productId,
      quantity: quantity,
      unitCost: unitCost,
      notes: notes,
    );
  }
}
