import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/store_setting.dart';
import '../../domain/entities/transaction_summary.dart';
import '../utils/media_url_resolver.dart';
import 'pdf_download_directory_service.dart';

class TransactionReportPdfService {
  const TransactionReportPdfService();

  static const _downloadDirectoryService = PdfDownloadDirectoryService();

  Future<Uint8List> buildPdf({
    required List<TransactionSummary> transactions,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
    StoreSetting? storeSetting,
  }) async {
    final document = pw.Document();
    final logo = await _loadLogo(storeSetting?.logoUrl);
    final totalNominal = transactions.fold<double>(
      0,
      (sum, transaction) => sum + _paymentNominal(transaction),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 30),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(22),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Center(
                    child: pw.Image(
                      logo,
                      width: 92,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                if (logo != null) pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    storeSetting?.storeName.trim().isNotEmpty == true
                        ? storeSetting!.storeName
                        : 'Folony Kasir',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    periodLabel,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Dicetak ${_formatDateTime(generatedAt)}',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Jumlah Transaksi',
                        value: '${transactions.length}',
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Total Nominal',
                        value: _rupiah(totalNominal),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                if (transactions.isEmpty)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F9FAFB'),
                      borderRadius: pw.BorderRadius.circular(16),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Text(
                      'Belum ada transaksi pada periode ini.',
                      textAlign: pw.TextAlign.center,
                    ),
                  )
                else
                  pw.TableHelper.fromTextArray(
                    headers: const [
                      'Tanggal',
                      'Invoice',
                      'Barang',
                      'Pembayaran',
                      'Nominal',
                      'Status',
                    ],
                    data: transactions
                        .map(
                          (transaction) => [
                            _formatDateTime(transaction.createdAt),
                            transaction.invoiceNumber,
                            _itemSummary(transaction.itemCount),
                            _displayPaymentMethod(transaction),
                            _rupiah(_paymentNominal(transaction)),
                            _paymentStatus(transaction.paymentStatus),
                          ],
                        )
                        .toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF97316),
                    ),
                    headerAlignments: _tableAlignments(),
                    cellAlignments: _tableAlignments(),
                    cellStyle: const pw.TextStyle(
                      fontSize: 10,
                    ),
                    cellPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    rowDecoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey300),
                      ),
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.5),
                      1: const pw.FlexColumnWidth(1.7),
                      2: const pw.FlexColumnWidth(1.0),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1.3),
                      5: const pw.FlexColumnWidth(1.1),
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<File> savePdf({
    required List<TransactionSummary> transactions,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
    StoreSetting? storeSetting,
    required String fileLabel,
  }) async {
    final bytes = await buildPdf(
      transactions: transactions,
      title: title,
      periodLabel: periodLabel,
      generatedAt: generatedAt,
      storeSetting: storeSetting,
    );

    final reportDir =
        await _downloadDirectoryService.resolveSubdirectory('Reports');

    final file = File(
      '${reportDir.path}${Platform.pathSeparator}${_safeFileName(fileLabel)}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.Widget _summaryCard({
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F9FAFB'),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, pw.Alignment> _tableAlignments() {
    return const {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerLeft,
      3: pw.Alignment.centerLeft,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerLeft,
    };
  }

  Future<pw.MemoryImage?> _loadLogo(String? logoUrl) async {
    final resolvedUrl = MediaUrlResolver.resolve(logoUrl);
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      try {
        final request = await HttpClient().getUrl(Uri.parse(resolvedUrl));
        final response = await request.close();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          if (bytes.isNotEmpty) {
            return pw.MemoryImage(bytes);
          }
        }
      } catch (_) {
        // Fallback to bundled logo below.
      }
    }

    try {
      final data = await rootBundle.load('assets/images/folony_logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  String _paymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'non_cash':
        return 'Non Tunai';
      case 'split':
        return 'Split';
      default:
        return method;
    }
  }

  String _displayPaymentMethod(TransactionSummary transaction) {
    if (transaction.memberPointValueAmount > 0 && transaction.grandTotal <= 0) {
      return 'Poin';
    }

    return _paymentMethod(transaction.paymentMethod);
  }

  String _paymentStatus(String status) {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Belum Lunas';
      default:
        return status;
    }
  }

  double _paymentNominal(TransactionSummary transaction) {
    return transaction.amountPaid + transaction.memberPointValueAmount;
  }

  String _itemSummary(int itemCount) {
    return '$itemCount item';
  }

  String _rupiah(double value) {
    final rounded = value.round();
    final digits = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }

  String _safeFileName(String label) {
    return label.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
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
}
