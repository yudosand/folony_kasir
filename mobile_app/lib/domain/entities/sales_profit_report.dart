import 'sales_profit_row.dart';

class SalesProfitReport {
  const SalesProfitReport({
    required this.transactionCount,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMarginPercent,
    required this.rows,
  });

  final int transactionCount;
  final int quantitySold;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMarginPercent;
  final List<SalesProfitRow> rows;
}
