import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/app/providers.dart';
import 'package:folony_kasir_mobile/domain/entities/sales_profit_report.dart';
import 'package:folony_kasir_mobile/domain/entities/sales_profit_row.dart';
import 'package:folony_kasir_mobile/domain/repositories/sales_profit_repository.dart';
import 'package:folony_kasir_mobile/domain/usecases/get_sales_profit_report_use_case.dart';
import 'package:folony_kasir_mobile/presentation/sales_profit/controllers/sales_profit_controller.dart';

void main() {
  group('SalesProfitController', () {
    late FakeSalesProfitRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeSalesProfitRepository();
      container = ProviderContainer(
        overrides: [
          getSalesProfitReportUseCaseProvider.overrideWithValue(
            GetSalesProfitReportUseCase(repository),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('applies payment and profit filters when refreshing report', () async {
      await container.read(salesProfitControllerProvider.future);

      final notifier = container.read(salesProfitControllerProvider.notifier);
      await notifier.setPaymentMethod('cash');
      await notifier.setProfitStatus('profit');

      final report = await container.read(salesProfitControllerProvider.future);

      expect(repository.lastPaymentMethod, 'cash');
      expect(repository.lastProfitStatus, 'profit');
      expect(report.totalProfit, 5000);
      expect(report.rows.single.productName, 'Produk Profit');
    });
  });
}

class FakeSalesProfitRepository implements SalesProfitRepository {
  String? lastPaymentMethod;
  String? lastProfitStatus;

  @override
  Future<SalesProfitReport> getReport({
    String? search,
    String? paymentMethod,
    String? profitStatus,
    String? dateFrom,
    String? dateTo,
  }) async {
    lastPaymentMethod = paymentMethod;
    lastProfitStatus = profitStatus;

    return const SalesProfitReport(
      transactionCount: 1,
      quantitySold: 2,
      totalRevenue: 9000,
      totalCost: 4000,
      totalProfit: 5000,
      profitMarginPercent: 55.56,
      rows: [
        SalesProfitRow(
          id: 1,
          transactionId: 10,
          invoiceNumber: 'INVTEST0001',
          productName: 'Produk Profit',
          paymentMethod: 'cash',
          paymentStatus: 'paid',
          cashierName: 'Kasir Test',
          quantity: 2,
          costPrice: 2000,
          sellingPrice: 4500,
          totalCost: 4000,
          totalSelling: 9000,
          totalProfit: 5000,
        ),
      ],
    );
  }
}
