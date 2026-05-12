import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/services/sales_profit_pdf_service.dart';
import '../../../core/utils/payment_display.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/sales_profit_report.dart';
import '../../../domain/entities/sales_profit_row.dart';
import '../../../domain/entities/store_setting.dart';
import '../controllers/sales_profit_controller.dart';

class SalesProfitPage extends ConsumerStatefulWidget {
  const SalesProfitPage({super.key});

  @override
  ConsumerState<SalesProfitPage> createState() => _SalesProfitPageState();
}

class _SalesProfitPageState extends ConsumerState<SalesProfitPage> {
  final _searchController = TextEditingController();
  final _pdfService = const SalesProfitPdfService();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesProfitControllerProvider);
    final notifier = ref.read(salesProfitControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: notifier.refresh,
              child: state.when(
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                  children: [
                    Text(
                      error is ApiException
                          ? error.message
                          : 'Laporan sales profit belum berhasil dimuat. Coba lagi ya.',
                    ),
                  ],
                ),
                data: (report) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: notifier.updateSearchQuery,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari produk, invoice, atau kasir',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          selected: notifier.paymentMethod == null,
                          onTap: () => notifier.setPaymentMethod(null),
                        ),
                        _FilterChip(
                          label: 'Tunai',
                          selected: notifier.paymentMethod == 'cash',
                          onTap: () => notifier.setPaymentMethod('cash'),
                        ),
                        _FilterChip(
                          label: 'Non Tunai',
                          selected: notifier.paymentMethod == 'non_cash',
                          onTap: () => notifier.setPaymentMethod('non_cash'),
                        ),
                        _FilterChip(
                          label: 'Split',
                          selected: notifier.paymentMethod == 'split',
                          onTap: () => notifier.setPaymentMethod('split'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'Semua Profit',
                          selected: notifier.profitStatus == null,
                          onTap: () => notifier.setProfitStatus(null),
                        ),
                        _FilterChip(
                          label: 'Untung',
                          selected: notifier.profitStatus == 'profit',
                          onTap: () => notifier.setProfitStatus('profit'),
                        ),
                        _FilterChip(
                          label: 'Impas',
                          selected: notifier.profitStatus == 'break_even',
                          onTap: () => notifier.setProfitStatus('break_even'),
                        ),
                        _FilterChip(
                          label: 'Rugi',
                          selected: notifier.profitStatus == 'loss',
                          onTap: () => notifier.setProfitStatus('loss'),
                        ),
                        _FilterChip(
                          label: notifier.dateRange == null
                              ? 'Pilih Periode'
                              : '${notifier.dateRange!.dateFrom} - ${notifier.dateRange!.dateTo}',
                          selected: notifier.dateRange != null,
                          onTap: () => _pickDateRange(notifier),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SummaryCards(report: report),
                    const SizedBox(height: 16),
                    if (report.rows.isEmpty)
                      const _EmptyState(
                        message: 'Belum ada data sales profit pada filter ini.',
                      )
                    else
                      ...report.rows.map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            row.productName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${row.invoiceNumber} • ${PaymentDisplay.paymentMethod(row.paymentMethod)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _ProfitPill(row: row),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_formatDateTime(row.transactionDate)} • ${row.cashierName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _MetricChip(
                                      label: 'Qty',
                                      value: '${row.quantity}',
                                    ),
                                    const SizedBox(width: 8),
                                    _MetricChip(
                                      label: 'Modal',
                                      value:
                                          RupiahFormatter.format(row.costPrice),
                                    ),
                                    const SizedBox(width: 8),
                                    _MetricChip(
                                      label: 'Jual',
                                      value: RupiahFormatter.format(
                                        row.sellingPrice,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      'Total Modal ${RupiahFormatter.format(row.totalCost)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'Total Jual ${RupiahFormatter.format(row.totalSelling)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _PageHeader(
                title: 'Sales Profit',
                onBack: () => context.pop(),
                onDownload: _isDownloading
                    ? null
                    : () => _downloadReport(state.valueOrNull),
                onShare:
                    _isSharing ? null : () => _shareReport(state.valueOrNull),
                isDownloading: _isDownloading,
                isSharing: _isSharing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(SalesProfitController notifier) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null || !mounted) {
      return;
    }

    await notifier.setDateRange(
      SalesProfitDateRangeFilter(
        dateFrom: _formatApiDate(picked.start),
        dateTo: _formatApiDate(picked.end),
      ),
    );
  }

  Future<void> _downloadReport(SalesProfitReport? report) async {
    if (report == null) {
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final storeSetting = await _loadStoreSettingSafe();
      final file = await _pdfService.savePdf(
        report: report,
        title: 'Laporan Sales Profit',
        periodLabel: _buildPeriodLabel(),
        generatedAt: DateTime.now(),
        storeSetting: storeSetting,
        fileLabel: 'laporan_sales_profit',
      );
      _showMessage('Laporan sales profit berhasil disimpan di ${file.path}');
    } catch (_) {
      _showMessage(
        'Laporan sales profit belum berhasil disimpan. Coba lagi ya.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _shareReport(SalesProfitReport? report) async {
    if (report == null) {
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final storeSetting = await _loadStoreSettingSafe();
      final file = await _pdfService.savePdf(
        report: report,
        title: 'Laporan Sales Profit',
        periodLabel: _buildPeriodLabel(),
        generatedAt: DateTime.now(),
        storeSetting: storeSetting,
        fileLabel: 'laporan_sales_profit',
      );

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: file.uri.pathSegments.last,
          ),
        ],
        text: 'Laporan sales profit Folony Kasir',
        subject: 'Laporan Sales Profit',
      );
    } catch (_) {
      _showMessage(
        'Laporan sales profit belum berhasil dibagikan. Coba lagi ya.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<StoreSetting?> _loadStoreSettingSafe() async {
    try {
      return await ref.read(getStoreSettingUseCaseProvider).call();
    } catch (_) {
      return null;
    }
  }

  String _buildPeriodLabel() {
    final range = ref.read(salesProfitControllerProvider.notifier).dateRange;
    if (range == null) {
      return 'Periode: Semua data';
    }

    return 'Periode: ${range.dateFrom} - ${range.dateTo}';
  }

  String _formatApiDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.report});

  final SalesProfitReport report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Omzet',
            value: RupiahFormatter.format(report.totalRevenue),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Modal',
            value: RupiahFormatter.format(report.totalCost),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Profit',
            value: RupiahFormatter.format(report.totalProfit),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _ProfitPill extends StatelessWidget {
  const _ProfitPill({required this.row});

  final SalesProfitRow row;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (row.profitStatusCode) {
      case 'loss':
        color = AppColors.danger;
        break;
      case 'break_even':
        color = const Color(0xFFB45309);
        break;
      default:
        color = const Color(0xFF166534);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${row.profitStatusLabel} • ${RupiahFormatter.format(row.totalProfit)}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.onBack,
    required this.onDownload,
    required this.onShare,
    required this.isDownloading,
    required this.isSharing,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final bool isDownloading;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: Color(0x12000000),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          InkWell(
            onTap: onShare,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 34,
              height: 34,
              child: isSharing
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share_outlined),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDownload,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 34,
              height: 34,
              child: isDownloading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

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
            Icons.assessment_outlined,
            size: 48,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          Text(
            message,
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
