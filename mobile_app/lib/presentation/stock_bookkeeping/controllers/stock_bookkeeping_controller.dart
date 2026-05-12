import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/stock_bookkeeping_report.dart';

final stockBookkeepingControllerProvider = AutoDisposeAsyncNotifierProvider<
    StockBookkeepingController, StockBookkeepingReport>(
  StockBookkeepingController.new,
);

class StockBookkeepingController
    extends AutoDisposeAsyncNotifier<StockBookkeepingReport> {
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _status;
  DateTimeRangeFilter? _dateRange;

  @override
  Future<StockBookkeepingReport> build() async {
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return _fetch();
  }

  String get searchQuery => _searchQuery;
  String? get status => _status;
  DateTimeRangeFilter? get dateRange => _dateRange;

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      refresh();
    });
  }

  Future<void> setStatus(String? status) async {
    _status = status;
    await refresh();
  }

  Future<void> setDateRange(DateTimeRangeFilter? dateRange) async {
    _dateRange = dateRange;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<StockBookkeepingReport> _fetch() {
    return ref.read(getStockBookkeepingReportUseCaseProvider).call(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          status: _status,
          dateFrom: _dateRange?.dateFrom,
          dateTo: _dateRange?.dateTo,
        );
  }
}

class DateTimeRangeFilter {
  const DateTimeRangeFilter({
    required this.dateFrom,
    required this.dateTo,
  });

  final String dateFrom;
  final String dateTo;
}
