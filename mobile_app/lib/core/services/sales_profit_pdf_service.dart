import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/sales_profit_report.dart';
import '../../domain/entities/store_setting.dart';
import '../utils/media_url_resolver.dart';
import '../utils/payment_display.dart';
import 'pdf_download_directory_service.dart';

class SalesProfitPdfService {
  const SalesProfitPdfService();

  static const _downloadDirectoryService = PdfDownloadDirectoryService();

  Future<Uint8List> buildPdf({
    required SalesProfitReport report,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
    StoreSetting? storeSetting,
  }) async {
    final document = pw.Document();
    final logo = await _loadLogo(storeSetting?.logoUrl);

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
                        label: 'Omzet',
                        value: _rupiah(report.totalRevenue),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Modal',
                        value: _rupiah(report.totalCost),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Profit',
                        value: _rupiah(report.totalProfit),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                if (report.rows.isEmpty)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F9FAFB'),
                      borderRadius: pw.BorderRadius.circular(16),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Text(
                      'Belum ada data sales profit pada filter ini.',
                      textAlign: pw.TextAlign.center,
                    ),
                  )
                else
                  pw.TableHelper.fromTextArray(
                    headers: const [
                      'Tanggal',
                      'Produk',
                      'Qty',
                      'Pembayaran',
                      'Harga Modal',
                      'Harga Jual',
                      'Profit',
                    ],
                    data: report.rows
                        .map(
                          (row) => [
                            _formatDateTime(row.transactionDate),
                            row.productName,
                            '${row.quantity}',
                            PaymentDisplay.paymentMethod(row.paymentMethod),
                            _rupiah(row.costPrice),
                            _rupiah(row.sellingPrice),
                            _rupiah(row.totalProfit),
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
                    cellStyle: const pw.TextStyle(fontSize: 10),
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
                      0: const pw.FlexColumnWidth(1.4),
                      1: const pw.FlexColumnWidth(2.3),
                      2: const pw.FlexColumnWidth(0.7),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1.2),
                      5: const pw.FlexColumnWidth(1.2),
                      6: const pw.FlexColumnWidth(1.2),
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
    required SalesProfitReport report,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
    StoreSetting? storeSetting,
    required String fileLabel,
  }) async {
    final bytes = await buildPdf(
      report: report,
      title: title,
      periodLabel: periodLabel,
      generatedAt: generatedAt,
      storeSetting: storeSetting,
    );

    final reportDir =
        await _downloadDirectoryService.resolveSubdirectory('SalesProfitReports');

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
        // Fallback below.
      }
    }

    try {
      final data = await rootBundle.load('assets/images/folony_logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  String _safeFileName(String label) {
    return label.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
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
