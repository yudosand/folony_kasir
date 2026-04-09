import '../entities/invoice.dart';
import '../entities/transaction_detail.dart';
import '../entities/transaction_input_item.dart';
import '../entities/transaction_summary.dart';

abstract class TransactionRepository {
  Future<TransactionDetail> createTransaction({
    required List<TransactionInputItem> items,
    required String paymentMethod,
    required double cashAmount,
    required double nonCashAmount,
    int? memberId,
    int? pointsUsed,
  });

  Future<List<TransactionSummary>> getTransactions({
    int perPage = 100,
    int page = 1,
    String? dateFrom,
    String? dateTo,
  });

  Future<Invoice> getInvoice(int transactionId);
}
