import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/services/invoice_pdf_service.dart';
import '../../../core/utils/payment_display.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/invoice.dart';
import '../../shared/widgets/brand_logo_badge.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../../transactions/controllers/invoice_controller.dart';

class InvoicePage extends ConsumerStatefulWidget {
  const InvoicePage({
    super.key,
    required this.transactionId,
  });

  final int transactionId;

  @override
  ConsumerState<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends ConsumerState<InvoicePage> {
  final _pdfService = const InvoicePdfService();
  bool _isSharing = false;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final invoiceState =
        ref.watch(invoiceControllerProvider(widget.transactionId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            invoiceState.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error is ApiException
                        ? error.message
                        : 'Invoice belum berhasil dimuat. Coba lagi ya.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (invoice) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 108, 20, 28),
                children: [
                  SurfaceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        BrandLogoBadge(
                          width: 96,
                          imageUrl: invoice.store.logoUrl,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          invoice.store.name ?? '-',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(invoice.issuedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        _InvoiceRow(
                          label: 'ID Trans',
                          value: invoice.invoiceNumber,
                        ),
                        _InvoiceRow(
                          label: 'Tanggal Transaksi',
                          value: _formatDate(invoice.issuedAt),
                        ),
                        _InvoiceRow(
                          label: 'Kasir',
                          value: invoice.cashier.name ?? '-',
                        ),
                        _InvoiceRow(
                          label: 'Metode Pembayaran',
                          value: _paymentMethodLabel(invoice),
                        ),
                        _InvoiceRow(
                          label: 'Status Pembayaran',
                          value: PaymentDisplay.paymentStatus(
                            invoice.payment.status,
                          ),
                        ),
                        const Divider(height: 26, color: AppColors.border),
                        for (final item in invoice.items) ...[
                          _InvoiceRow(
                            label:
                                '${item.productName}\n${item.quantity} x ${RupiahFormatter.format(item.sellingPrice)}',
                            value: RupiahFormatter.format(item.lineSubtotal),
                          ),
                          const Divider(height: 18, color: AppColors.border),
                        ],
                        ..._buildPaymentRows(invoice),
                        if ((invoice.store.invoiceFooter ?? '').isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            invoice.store.invoiceFooter!,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSharing || _isDownloading
                              ? null
                              : () => _sharePdf(invoice),
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.share_outlined),
                          label: Text(_isSharing ? 'Menyiapkan...' : 'Bagikan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showPrintComingSoon(context),
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _isSharing || _isDownloading
                        ? null
                        : () => _downloadPdf(invoice),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Download PDF'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE3D8),
                      foregroundColor: AppColors.primary,
                      side: BorderSide.none,
                    ),
                    child: const Text('Buat Transaksi Baru'),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DemoScreenHeader(
                title: 'Transaksi Berhasil',
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
                leading: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdf(Invoice invoice) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final file = await _pdfService.savePdf(invoice);
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: file.uri.pathSegments.isEmpty
                ? 'invoice.pdf'
                : file.uri.pathSegments.last,
          ),
        ],
        text: 'Invoice ${invoice.invoiceNumber}',
        subject: 'Invoice ${invoice.invoiceNumber}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('PDF belum berhasil dibagikan. Coba lagi ya.');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _downloadPdf(Invoice invoice) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final file = await _pdfService.savePdf(invoice);
      if (!mounted) {
        return;
      }

      _showMessage('PDF berhasil disimpan di ${file.path}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('PDF belum berhasil disimpan. Coba lagi ya.');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  List<Widget> _buildPaymentRows(Invoice invoice) {
    if (_isFullyPaidByPoints(invoice)) {
      return <Widget>[
        _InvoiceRow(
          label: 'Total Produk',
          value: RupiahFormatter.format(invoice.totals.subtotal),
          isStrong: true,
        ),
        _InvoiceRow(
          label: 'Potongan Poin Member',
          value: '-${RupiahFormatter.format(invoice.memberPoints.valueAmount)}',
        ),
      ];
    }

    final rows = <Widget>[
      _InvoiceRow(
        label: 'Total Produk',
        value: RupiahFormatter.format(invoice.totals.subtotal),
        isStrong: true,
      ),
    ];

    if (invoice.memberPoints.pointsUsed > 0) {
      rows.add(
        _InvoiceRow(
          label: 'Potongan Poin Member',
          value: '-${RupiahFormatter.format(invoice.memberPoints.valueAmount)}',
        ),
      );
      rows.add(
        _InvoiceRow(
          label: 'Grand Total',
          value: RupiahFormatter.format(invoice.totals.grandTotal),
          isStrong: true,
        ),
      );
      rows.add(
        _InvoiceRow(
          label: 'Dibayar Poin Member',
          value: RupiahFormatter.format(invoice.memberPoints.valueAmount),
        ),
      );
    }

    if (invoice.payment.cashAmount > 0) {
      rows.add(
        _InvoiceRow(
          label: 'Uang Tunai',
          value: RupiahFormatter.format(invoice.payment.cashAmount),
        ),
      );
    }

    if (invoice.payment.nonCashAmount > 0) {
      rows.add(
        _InvoiceRow(
          label: 'Uang Non Tunai',
          value: RupiahFormatter.format(invoice.payment.nonCashAmount),
        ),
      );
    }

    rows.add(
      _InvoiceRow(
        label: 'Total Dibayar',
        value: RupiahFormatter.format(
          invoice.payment.amountPaid + invoice.memberPoints.valueAmount,
        ),
        isStrong: true,
      ),
    );

    if (invoice.payment.changeAmount > 0) {
      rows.add(
        _InvoiceRow(
          label: 'Kembalian',
          value: RupiahFormatter.format(invoice.payment.changeAmount),
        ),
      );
    }

    if (invoice.payment.dueAmount > 0) {
      rows.add(
        _InvoiceRow(
          label: 'Kurang Bayar',
          value: RupiahFormatter.format(invoice.payment.dueAmount),
        ),
      );
    }

    return rows;
  }

  bool _isFullyPaidByPoints(Invoice invoice) {
    return invoice.memberPoints.pointsUsed > 0 && invoice.totals.grandTotal <= 0;
  }

  String _paymentMethodLabel(Invoice invoice) {
    if (_isFullyPaidByPoints(invoice)) {
      return 'Poin';
    }

    return PaymentDisplay.paymentMethod(invoice.payment.method);
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

  void _showPrintComingSoon(BuildContext context) {
    _showMessage('Fitur print masih dalam pengembangan.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isStrong ? FontWeight.w800 : FontWeight.w700,
                    color: isStrong ? AppColors.textPrimary : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
