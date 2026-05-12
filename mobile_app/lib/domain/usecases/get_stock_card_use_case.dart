import '../entities/stock_card.dart';
import '../repositories/stock_bookkeeping_repository.dart';

class GetStockCardUseCase {
  const GetStockCardUseCase(this._repository);

  final StockBookkeepingRepository _repository;

  Future<StockCard> call(
    int productId, {
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.getStockCard(
      productId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
