import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/services/transaction_report_pdf_service.dart';
import '../../../core/utils/payment_display.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../cart/controllers/checkout_controller.dart';
import '../../manual_transaction/controllers/manual_transaction_controller.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../controllers/transaction_list_controller.dart';
import '../../../domain/entities/transaction_summary.dart';

enum _HistoryFilter { all, today, thisWeek, thisMonth, customRange }

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  late final TextEditingController _searchController;
  final _reportPdfService = const TransactionReportPdfService();
  _HistoryFilter _activeFilter = _HistoryFilter.all;
  DateTimeRange? _selectedDateRange;
  bool _isDownloadingReport = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref
                  .read(transactionListControllerProvider.notifier)
                  .refreshTransactions(),
              child: state.when(
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                  children: [
                    Text(
                      error is ApiException
                          ? error.message
                          : 'Riwayat transaksi belum berhasil dimuat. Coba lagi ya.',
                    ),
                  ],
                ),
                data: (transactions) {
                  final filteredTransactions =
                      _applyFilters(transactions, _searchController.text);

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                    children: [
                      _HistorySearchBar(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _HistoryFilterChips(
                        activeFilter: _activeFilter,
                        selectedDateRange: _selectedDateRange,
                        onFilterChanged: _handleFilterChanged,
                      ),
                      const SizedBox(height: 16),
                      if (transactions.isEmpty)
                        const _EmptyTransactionState()
                      else if (filteredTransactions.isEmpty)
                        const _EmptyFilteredState()
                      else
                        ...List.generate(filteredTransactions.length, (index) {
                          final transaction = filteredTransactions[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == filteredTransactions.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.push(
                                AppRoutes.transactionInvoice(transaction.id),
                              ),
                              child: SurfaceCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.invoiceNumber,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${_formatDate(transaction.createdAt)} - ${PaymentDisplay.paymentMethod(transaction.paymentMethod)} - ${PaymentDisplay.paymentStatus(transaction.paymentStatus)}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          RupiahFormatter.format(
                                            transaction.grandTotal,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${transaction.itemCount} item',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DemoScreenHeader(
                title: 'Riwayat Transaksi',
                height: 50,
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0x12000000),
                  ),
                ),
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                trailing: InkWell(
                  onTap: null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _isDownloadingReport
                            ? null
                            : () => _showReportFilterSheet(),
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: _isDownloadingReport
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.download_rounded,
                                  color: AppColors.textPrimary,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          ref
                              .read(manualTransactionControllerProvider.notifier)
                              .clear();
                          ref.read(checkoutControllerProvider.notifier).reset();
                          context.go(AppRoutes.manualTransaction);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            Icons.post_add_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReportFilterSheet() async {
    final selected = await showModalBottomSheet<_HistoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportFilterSheet(
        selectedDateRange: _selectedDateRange,
      ),
    );

    if (selected == null || !mounted) {
      return;
    }

    DateTimeRange? customRange;
    if (selected == _HistoryFilter.customRange) {
      final now = DateTime.now();
      customRange = await showDateRangePicker(
        context: context,
        initialDateRange: _selectedDateRange,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year + 2),
      );

      if (customRange == null || !mounted) {
        return;
      }
    }

    await _downloadReport(
      filter: selected,
      customRange: customRange,
    );
  }

  Future<void> _downloadReport({
    required _HistoryFilter filter,
    DateTimeRange? customRange,
  }) async {
    setState(() {
      _isDownloadingReport = true;
    });

    try {
      final range = _resolveDateRange(filter, customRange);
      final transactions = await _fetchTransactionsForReport(
        dateFrom: range?.$1 != null ? _formatApiDate(range!.$1) : null,
        dateTo: range?.$2 != null ? _formatApiDate(range!.$2) : null,
      );
      final storeSetting =
          await ref.read(getStoreSettingUseCaseProvider).call();
      final file = await _reportPdfService.savePdf(
        transactions: transactions,
        title: 'Rekap Transaksi',
        periodLabel: _reportPeriodLabel(filter, customRange),
        generatedAt: DateTime.now(),
        storeSetting: storeSetting,
        fileLabel: _reportFileLabel(filter, customRange),
      );

      if (!mounted) {
        return;
      }

      _showMessage('Rekap transaksi berhasil disimpan di ${file.path}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is ApiException
          ? error.message
          : 'Rekap transaksi belum berhasil dibuat. Coba lagi ya.';
      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingReport = false;
        });
      }
    }
  }

  (DateTime, DateTime)? _resolveDateRange(
    _HistoryFilter filter,
    DateTimeRange? customRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case _HistoryFilter.all:
        return null;
      case _HistoryFilter.today:
        return (today, today);
      case _HistoryFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return (startOfWeek, endOfWeek);
      case _HistoryFilter.thisMonth:
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return (startOfMonth, endOfMonth);
      case _HistoryFilter.customRange:
        if (customRange == null) {
          return null;
        }
        return (
          DateTime(
            customRange.start.year,
            customRange.start.month,
            customRange.start.day,
          ),
          DateTime(
            customRange.end.year,
            customRange.end.month,
            customRange.end.day,
          ),
        );
    }
  }

  String _formatApiDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<List<TransactionSummary>> _fetchTransactionsForReport({
    String? dateFrom,
    String? dateTo,
  }) async {
    final transactions = <TransactionSummary>[];
    var page = 1;

    while (true) {
      final pageItems = await ref.read(getTransactionsUseCaseProvider).call(
            perPage: 100,
            page: page,
            dateFrom: dateFrom,
            dateTo: dateTo,
          );

      if (pageItems.isEmpty) {
        break;
      }

      transactions.addAll(pageItems);

      if (pageItems.length < 100) {
        break;
      }

      page += 1;
    }

    return transactions;
  }

  String _reportPeriodLabel(
    _HistoryFilter filter,
    DateTimeRange? customRange,
  ) {
    switch (filter) {
      case _HistoryFilter.all:
        return 'Semua Transaksi';
      case _HistoryFilter.today:
        return 'Periode: Hari Ini';
      case _HistoryFilter.thisWeek:
        return 'Periode: Minggu Ini';
      case _HistoryFilter.thisMonth:
        return 'Periode: Bulan Ini';
      case _HistoryFilter.customRange:
        if (customRange == null) {
          return 'Periode: Rentang Tanggal';
        }
        return 'Periode: ${_formatShortDate(customRange.start)} - ${_formatShortDate(customRange.end)}';
    }
  }

  String _reportFileLabel(
    _HistoryFilter filter,
    DateTimeRange? customRange,
  ) {
    switch (filter) {
      case _HistoryFilter.all:
        return 'rekap_transaksi_semua';
      case _HistoryFilter.today:
        return 'rekap_transaksi_hari_ini';
      case _HistoryFilter.thisWeek:
        return 'rekap_transaksi_minggu_ini';
      case _HistoryFilter.thisMonth:
        return 'rekap_transaksi_bulan_ini';
      case _HistoryFilter.customRange:
        if (customRange == null) {
          return 'rekap_transaksi_rentang';
        }
        return 'rekap_transaksi_${_formatApiDate(customRange.start)}_${_formatApiDate(customRange.end)}';
    }
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _handleFilterChanged(_HistoryFilter nextFilter) async {
    if (nextFilter == _HistoryFilter.customRange) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        initialDateRange: _selectedDateRange,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year + 2),
      );

      if (picked == null || !mounted) {
        return;
      }

      setState(() {
        _activeFilter = _HistoryFilter.customRange;
        _selectedDateRange = DateTimeRange(
          start: DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          ),
          end: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
          ),
        );
      });
      return;
    }

    setState(() {
      _activeFilter = nextFilter;
      if (nextFilter != _HistoryFilter.customRange) {
        _selectedDateRange = null;
      }
    });
  }

  List<TransactionSummary> _applyFilters(
    List<TransactionSummary> transactions,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesQuery = normalizedQuery.isEmpty ||
          transaction.invoiceNumber.toLowerCase().contains(normalizedQuery) ||
          PaymentDisplay.paymentMethod(transaction.paymentMethod)
              .toLowerCase()
              .contains(normalizedQuery) ||
          PaymentDisplay.paymentStatus(transaction.paymentStatus)
              .toLowerCase()
              .contains(normalizedQuery);

      if (!matchesQuery) {
        return false;
      }

      return _matchesDateFilter(transaction.createdAt);
    }).toList();
  }

  bool _matchesDateFilter(DateTime? createdAt) {
    if (_activeFilter == _HistoryFilter.all) {
      return true;
    }

    if (createdAt == null) {
      return false;
    }

    final localDate = DateTime(createdAt.toLocal().year,
        createdAt.toLocal().month, createdAt.toLocal().day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_activeFilter) {
      case _HistoryFilter.all:
        return true;
      case _HistoryFilter.today:
        return localDate == today;
      case _HistoryFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return !localDate.isBefore(startOfWeek) &&
            localDate.isBefore(endOfWeek);
      case _HistoryFilter.thisMonth:
        return localDate.year == today.year && localDate.month == today.month;
      case _HistoryFilter.customRange:
        if (_selectedDateRange == null) {
          return true;
        }
        return !localDate.isBefore(_selectedDateRange!.start) &&
            !localDate.isAfter(_selectedDateRange!.end);
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year, $hour.$minute';
  }
}

class _HistorySearchBar extends StatelessWidget {
  const _HistorySearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Cari invoice atau pembayaran',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _ReportFilterSheet extends StatelessWidget {
  const _ReportFilterSheet({
    required this.selectedDateRange,
  });

  final DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Download Rekap Transaksi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih periode transaksi yang ingin kamu simpan ke PDF.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                ...[
                  ('Semua Transaksi', _HistoryFilter.all),
                  ('Hari Ini', _HistoryFilter.today),
                  ('Minggu Ini', _HistoryFilter.thisWeek),
                  ('Bulan Ini', _HistoryFilter.thisMonth),
                  (
                    selectedDateRange == null
                        ? 'Pilih Rentang Tanggal'
                        : 'Rentang: ${_formatShortDate(selectedDateRange!.start)} - ${_formatShortDate(selectedDateRange!.end)}',
                    _HistoryFilter.customRange,
                  ),
                ].map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).pop(entry.$2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.$1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}

class _HistoryFilterChips extends StatelessWidget {
  const _HistoryFilterChips({
    required this.activeFilter,
    required this.selectedDateRange,
    required this.onFilterChanged,
  });

  final _HistoryFilter activeFilter;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<_HistoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipButton(
          label: 'Semua',
          isSelected: activeFilter == _HistoryFilter.all,
          onTap: () => onFilterChanged(_HistoryFilter.all),
        ),
        _FilterChipButton(
          label: 'Hari Ini',
          isSelected: activeFilter == _HistoryFilter.today,
          onTap: () => onFilterChanged(_HistoryFilter.today),
        ),
        _FilterChipButton(
          label: 'Minggu Ini',
          isSelected: activeFilter == _HistoryFilter.thisWeek,
          onTap: () => onFilterChanged(_HistoryFilter.thisWeek),
        ),
        _FilterChipButton(
          label: 'Bulan Ini',
          isSelected: activeFilter == _HistoryFilter.thisMonth,
          onTap: () => onFilterChanged(_HistoryFilter.thisMonth),
        ),
        _FilterChipButton(
          label: selectedDateRange == null
              ? 'Pilih Rentang'
              : '${_formatShortDate(selectedDateRange!.start)} - ${_formatShortDate(selectedDateRange!.end)}',
          isSelected: activeFilter == _HistoryFilter.customRange,
          onTap: () => onFilterChanged(_HistoryFilter.customRange),
        ),
      ],
    );
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _EmptyTransactionState extends StatelessWidget {
  const _EmptyTransactionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada transaksi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaksi yang berhasil checkout akan muncul di sini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilteredState extends StatelessWidget {
  const _EmptyFilteredState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          Text(
            'Transaksi tidak ditemukan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ganti kata kunci atau filter tanggalnya.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
