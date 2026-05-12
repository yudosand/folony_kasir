import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/sales_profit_report.dart';

final salesProfitControllerProvider =
    AutoDisposeAsyncNotifierProvider<SalesProfitController, SalesProfitReport>(
  SalesProfitController.new,
);

class SalesProfitController
    extends AutoDisposeAsyncNotifier<SalesProfitReport> {
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _paymentMethod;
  String? _profitStatus;
  SalesProfitDateRangeFilter? _dateRange;

  @override
  Future<SalesProfitReport> build() async {
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return _fetch();
  }

  String get searchQuery => _searchQuery;
  String? get paymentMethod => _paymentMethod;
  String? get profitStatus => _profitStatus;
  SalesProfitDateRangeFilter? get dateRange => _dateRange;

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      refresh();
    });
  }

  Future<void> setPaymentMethod(String? paymentMethod) async {
    _paymentMethod = paymentMethod;
    await refresh();
  }

  Future<void> setProfitStatus(String? profitStatus) async {
    _profitStatus = profitStatus;
    await refresh();
  }

  Future<void> setDateRange(SalesProfitDateRangeFilter? dateRange) async {
    _dateRange = dateRange;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<SalesProfitReport> _fetch() {
    return ref.read(getSalesProfitReportUseCaseProvider).call(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          paymentMethod: _paymentMethod,
          profitStatus: _profitStatus,
          dateFrom: _dateRange?.dateFrom,
          dateTo: _dateRange?.dateTo,
        );
  }
}

class SalesProfitDateRangeFilter {
  const SalesProfitDateRangeFilter({
    required this.dateFrom,
    required this.dateTo,
  });

  final String dateFrom;
  final String dateTo;
}
