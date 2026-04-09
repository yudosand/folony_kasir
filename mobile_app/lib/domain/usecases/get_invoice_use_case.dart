import '../entities/invoice.dart';
import '../repositories/transaction_repository.dart';

class GetInvoiceUseCase {
  const GetInvoiceUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Invoice> call(int transactionId) {
    return _repository.getInvoice(transactionId);
  }
}
