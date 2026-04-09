import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/invoice.dart';
import '../utils/media_url_resolver.dart';
import 'pdf_download_directory_service.dart';

class InvoicePdfService {
  const InvoicePdfService();

  static const _downloadDirectoryService = PdfDownloadDirectoryService();

  Future<Uint8List> buildPdf(Invoice invoice) async {
    final document = pw.Document();
    final logo = await _loadLogo(invoice.store.logoUrl);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
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
              children: [
                if (logo != null)
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#FFF2EA'),
                        borderRadius: pw.BorderRadius.circular(18),
                      ),
                      child: pw.Image(
                        logo,
                        width: 110,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                if (logo != null) pw.SizedBox(height: 18),
                pw.Text(
                  invoice.store.name ?? '-',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 19,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.invoiceNumber,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 18),
                _detailRow('ID Trans', invoice.invoiceNumber),
                _detailRow('Tanggal Transaksi', _formatDate(invoice.issuedAt)),
                _detailRow('Kasir', invoice.cashier.name ?? '-'),
                _detailRow(
                  'Metode Pembayaran',
                  _paymentMethod(invoice),
                ),
                _detailRow(
                  'Status Pembayaran',
                  _paymentStatus(invoice.payment.status),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 6),
                for (final item in invoice.items) ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.productName,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '${item.quantity} x ${_rupiah(item.sellingPrice)}',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          _rupiah(item.lineSubtotal),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(color: PdfColors.grey200),
                ],
                ..._paymentBreakdownRows(invoice),
                if ((invoice.store.invoiceFooter ?? '').isNotEmpty) ...[
                  pw.SizedBox(height: 18),
                  pw.Center(
                    child: pw.Text(
                      invoice.store.invoiceFooter!,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<File> savePdf(Invoice invoice) async {
    final bytes = await buildPdf(invoice);
    final invoiceDir =
        await _downloadDirectoryService.resolveSubdirectory('Invoices');

    final file = File(
      '${invoiceDir.path}${Platform.pathSeparator}${_safeFileName(invoice.invoiceNumber)}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
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

  pw.Widget _detailRow(String label, String value, {bool strong = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: strong ? 12 : 11,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
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

  String _safeFileName(String invoiceNumber) {
    return 'invoice_${invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}';
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

  List<pw.Widget> _paymentBreakdownRows(Invoice invoice) {
    if (_isFullyPaidByPoints(invoice)) {
      return <pw.Widget>[
        pw.SizedBox(height: 6),
        _detailRow(
          'Total Produk',
          _rupiah(invoice.totals.subtotal),
          strong: true,
        ),
        _detailRow(
          'Potongan Poin Member',
          '-${_rupiah(invoice.memberPoints.valueAmount)}',
        ),
      ];
    }

    final rows = <pw.Widget>[
      pw.SizedBox(height: 6),
      _detailRow(
        'Total Produk',
        _rupiah(invoice.totals.subtotal),
        strong: true,
      ),
    ];

    if (invoice.memberPoints.pointsUsed > 0) {
      rows.add(
        _detailRow(
          'Potongan Poin Member',
          '-${_rupiah(invoice.memberPoints.valueAmount)}',
        ),
      );
      rows.add(
        _detailRow(
          'Grand Total',
          _rupiah(invoice.totals.grandTotal),
          strong: true,
        ),
      );
      rows.add(
        _detailRow(
          'Dibayar Poin Member',
          _rupiah(invoice.memberPoints.valueAmount),
        ),
      );
    }

    if (invoice.payment.cashAmount > 0) {
      rows.add(_detailRow('Uang Tunai', _rupiah(invoice.payment.cashAmount)));
    }

    if (invoice.payment.nonCashAmount > 0) {
      rows.add(
        _detailRow('Uang Non Tunai', _rupiah(invoice.payment.nonCashAmount)),
      );
    }

    rows.add(
      _detailRow(
        'Total Dibayar',
        _rupiah(invoice.payment.amountPaid + invoice.memberPoints.valueAmount),
        strong: true,
      ),
    );

    if (invoice.payment.changeAmount > 0) {
      rows.add(_detailRow('Kembalian', _rupiah(invoice.payment.changeAmount)));
    }

    if (invoice.payment.dueAmount > 0) {
      rows.add(_detailRow('Kurang Bayar', _rupiah(invoice.payment.dueAmount)));
    }

    return rows;
  }

  bool _isFullyPaidByPoints(Invoice invoice) {
    return invoice.memberPoints.pointsUsed > 0 && invoice.totals.grandTotal <= 0;
  }

  String _paymentMethod(Invoice invoice) {
    if (_isFullyPaidByPoints(invoice)) {
      return 'Poin';
    }

    final method = invoice.payment.method;

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

  String _paymentStatus(String status) {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Parsial';
      default:
        return status;
    }
  }
}
