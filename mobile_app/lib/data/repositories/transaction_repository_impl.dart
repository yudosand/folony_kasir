import '../../domain/entities/invoice.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/entities/transaction_input_item.dart';
import '../../domain/entities/transaction_summary.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._remoteDataSource);

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<TransactionDetail> createTransaction({
    required List<TransactionInputItem> items,
    required String paymentMethod,
    required double cashAmount,
    required double nonCashAmount,
    int? memberId,
    int? pointsUsed,
  }) async {
    final response = await _remoteDataSource.createTransaction(
      items: items
          .map(
            (item) => {
              if (item.productId != null) 'product_id': item.productId,
              if (item.productId == null) 'product_name': item.name,
              'quantity': item.quantity,
              if (item.productId == null) 'unit_price': item.unitPrice,
            },
          )
          .toList(),
      paymentMethod: paymentMethod,
      cashAmount: cashAmount,
      nonCashAmount: nonCashAmount,
      memberId: memberId,
      pointsUsed: pointsUsed,
    );

    return response.toDetail();
  }

  @override
  Future<List<TransactionSummary>> getTransactions({
    int perPage = 100,
    int page = 1,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _remoteDataSource.getTransactions(
      perPage: perPage,
      page: page,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    return response.transactions
        .map((transaction) => transaction.toSummary())
        .toList();
  }

  @override
  Future<Invoice> getInvoice(int transactionId) async {
    final response = await _remoteDataSource.getInvoice(transactionId);
    return response.toEntity();
  }
}
