import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/stock_bookkeeping_report.dart';
import 'pdf_download_directory_service.dart';

class StockBookkeepingPdfService {
  const StockBookkeepingPdfService();

  static const _downloadDirectoryService = PdfDownloadDirectoryService();

  Future<Uint8List> buildPdf({
    required StockBookkeepingReport report,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
  }) async {
    final document = pw.Document();

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
                pw.Center(
                  child: pw.Text(
                    'Folony Kasir',
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
                        label: 'Jumlah Produk',
                        value: '${report.productCount}',
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Perlu Restock',
                        value: '${report.needsRestockCount}',
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Habis',
                        value: '${report.outOfStockCount}',
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _summaryCard(
                        label: 'Menipis',
                        value: '${report.lowStockCount}',
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
                      'Belum ada data pembukuan stok pada filter ini.',
                      textAlign: pw.TextAlign.center,
                    ),
                  )
                else
                  pw.TableHelper.fromTextArray(
                    headers: const [
                      'Produk',
                      'Stok Awal',
                      'Awal Periode',
                      'Masuk',
                      'Keluar',
                      'Stok Kini',
                      'Min. Stok',
                      'Status',
                    ],
                    data: report.rows
                        .map(
                          (row) => [
                            row.productName,
                            '${row.initialStock}',
                            '${row.stockAtPeriodStart}',
                            '${row.stockIn}',
                            '${row.stockOut}',
                            '${row.currentStock}',
                            '${row.minimumStock}',
                            row.stockStatusLabel,
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
                      0: const pw.FlexColumnWidth(2.4),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(1),
                      6: const pw.FlexColumnWidth(1),
                      7: const pw.FlexColumnWidth(1.2),
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
    required StockBookkeepingReport report,
    required String title,
    required String periodLabel,
    required DateTime generatedAt,
    required String fileLabel,
  }) async {
    final bytes = await buildPdf(
      report: report,
      title: title,
      periodLabel: periodLabel,
      generatedAt: generatedAt,
    );

    final reportDir =
        await _downloadDirectoryService.resolveSubdirectory('StockReports');

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

  String _safeFileName(String label) {
    return label.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
