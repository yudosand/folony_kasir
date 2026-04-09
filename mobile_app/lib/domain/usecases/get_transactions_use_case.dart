import '../entities/transaction_summary.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  const GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Future<List<TransactionSummary>> call({
    int perPage = 100,
    int page = 1,
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.getTransactions(
      perPage: perPage,
      page: page,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
