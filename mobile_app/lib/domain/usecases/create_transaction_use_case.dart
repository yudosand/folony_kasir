import '../entities/transaction_detail.dart';
import '../entities/transaction_input_item.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  const CreateTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<TransactionDetail> call({
    required List<TransactionInputItem> items,
    required String paymentMethod,
    required double cashAmount,
    required double nonCashAmount,
    int? memberId,
    int? pointsUsed,
  }) {
    return _repository.createTransaction(
      items: items,
      paymentMethod: paymentMethod,
      cashAmount: cashAmount,
      nonCashAmount: nonCashAmount,
      memberId: memberId,
      pointsUsed: pointsUsed,
    );
  }
}
