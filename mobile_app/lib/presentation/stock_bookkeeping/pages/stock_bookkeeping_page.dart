import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/services/stock_bookkeeping_pdf_service.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/stock_bookkeeping_report.dart';
import '../controllers/stock_bookkeeping_controller.dart';

class StockBookkeepingPage extends ConsumerStatefulWidget {
  const StockBookkeepingPage({super.key});

  @override
  ConsumerState<StockBookkeepingPage> createState() =>
      _StockBookkeepingPageState();
}

class _StockBookkeepingPageState extends ConsumerState<StockBookkeepingPage> {
  final _searchController = TextEditingController();
  final _pdfService = const StockBookkeepingPdfService();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockBookkeepingControllerProvider);
    final notifier = ref.read(stockBookkeepingControllerProvider.notifier);

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
                          : 'Pembukuan stok belum berhasil dimuat. Coba lagi ya.',
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
                        hintText: 'Cari produk pembukuan stok',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
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
                    _SummaryCards(
                      report: report,
                      selectedStatus: notifier.status,
                      onSelectStatus: notifier.setStatus,
                    ),
                    const SizedBox(height: 16),
                    if (report.rows.isEmpty)
                      const _EmptyState(
                        message:
                            'Belum ada data pembukuan stok pada filter ini.',
                      )
                    else
                      ...report.rows.map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push(
                              AppRoutes.stockProductDetail(row.productId),
                            ),
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
                                        child: Text(
                                          row.productName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      _StatusPill(
                                        label: row.stockStatusLabel,
                                        status: row.stockStatus,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Stok kini ${row.currentStock} • Min ${row.minimumStock}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _MetricChip(
                                        label: 'Awal',
                                        value: '${row.initialStock}',
                                      ),
                                      const SizedBox(width: 8),
                                      _MetricChip(
                                        label: 'Masuk',
                                        value: '${row.stockIn}',
                                      ),
                                      const SizedBox(width: 8),
                                      _MetricChip(
                                        label: 'Keluar',
                                        value: '${row.stockOut}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Harga jual ${RupiahFormatter.format(row.sellingPrice)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
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
                title: 'Pembukuan Stok',
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

  Future<void> _pickDateRange(StockBookkeepingController notifier) async {
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
      DateTimeRangeFilter(
        dateFrom: _formatApiDate(picked.start),
        dateTo: _formatApiDate(picked.end),
      ),
    );
  }

  Future<void> _downloadReport(StockBookkeepingReport? report) async {
    if (report == null) {
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final file = await _pdfService.savePdf(
        report: report,
        title: 'Laporan Pembukuan Stok',
        periodLabel: _buildPeriodLabel(),
        generatedAt: DateTime.now(),
        fileLabel: 'laporan_pembukuan_stok',
      );
      _showMessage('Laporan stok berhasil disimpan di ${file.path}');
    } catch (_) {
      _showMessage('Laporan stok belum berhasil disimpan. Coba lagi ya.');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _shareReport(StockBookkeepingReport? report) async {
    if (report == null) {
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final file = await _pdfService.savePdf(
        report: report,
        title: 'Laporan Pembukuan Stok',
        periodLabel: _buildPeriodLabel(),
        generatedAt: DateTime.now(),
        fileLabel: 'laporan_pembukuan_stok',
      );

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: file.uri.pathSegments.last,
          ),
        ],
        text: 'Laporan pembukuan stok Folony Kasir',
        subject: 'Laporan Pembukuan Stok',
      );
    } catch (_) {
      _showMessage('Laporan stok belum berhasil dibagikan. Coba lagi ya.');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _buildPeriodLabel() {
    final range = ref.read(stockBookkeepingControllerProvider.notifier).dateRange;
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
  const _SummaryCards({
    required this.report,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  final StockBookkeepingReport report;
  final String? selectedStatus;
  final Future<void> Function(String? status) onSelectStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCardButton(
                label: 'Semua',
                value: '${report.productCount}',
                selected: selectedStatus == null,
                onTap: () => onSelectStatus(null),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCardButton(
                label: 'Aman',
                value: '${report.healthyCount}',
                selected: selectedStatus == 'healthy',
                onTap: () => onSelectStatus('healthy'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCardButton(
                label: 'Menipis',
                value: '${report.lowStockCount}',
                selected: selectedStatus == 'low',
                onTap: () => onSelectStatus('low'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCardButton(
                label: 'Habis',
                value: '${report.outOfStockCount}',
                selected: selectedStatus == 'out',
                onTap: () => onSelectStatus('out'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCardButton(
                label: 'Perlu Restock',
                value: '${report.needsRestockCount}',
                selected: selectedStatus == 'restock',
                onTap: () => onSelectStatus('restock'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCardButton extends StatelessWidget {
  const _SummaryCardButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0x14000000),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.status,
  });

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'out':
        color = AppColors.danger;
        break;
      case 'low':
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
        label,
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
            Icons.inventory_2_outlined,
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
