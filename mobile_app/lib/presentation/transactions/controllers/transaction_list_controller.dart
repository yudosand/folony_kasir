import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/transaction_summary.dart';

final transactionListControllerProvider = AutoDisposeAsyncNotifierProvider<
    TransactionListController, List<TransactionSummary>>(
  TransactionListController.new,
);

class TransactionListController
    extends AutoDisposeAsyncNotifier<List<TransactionSummary>> {
  @override
  Future<List<TransactionSummary>> build() {
    return _fetchTransactions();
  }

  Future<void> refreshTransactions() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTransactions);
  }

  Future<List<TransactionSummary>> _fetchTransactions() {
    return ref.read(getTransactionsUseCaseProvider).call();
  }
}
