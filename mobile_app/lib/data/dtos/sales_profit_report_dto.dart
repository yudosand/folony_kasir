import '../../domain/entities/sales_profit_report.dart';
import 'sales_profit_row_dto.dart';

class SalesProfitReportDto {
  const SalesProfitReportDto({
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
  final List<SalesProfitRowDto> rows;

  factory SalesProfitReportDto.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    final rawRows = json['rows'] as List<dynamic>? ?? const [];

    return SalesProfitReportDto(
      transactionCount: (summary['transaction_count'] as num?)?.toInt() ?? 0,
      quantitySold: (summary['quantity_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: (summary['total_revenue'] as num?)?.toDouble() ?? 0,
      totalCost: (summary['total_cost'] as num?)?.toDouble() ?? 0,
      totalProfit: (summary['total_profit'] as num?)?.toDouble() ?? 0,
      profitMarginPercent:
          (summary['profit_margin_percent'] as num?)?.toDouble() ?? 0,
      rows: rawRows
          .whereType<Map<String, dynamic>>()
          .map(SalesProfitRowDto.fromJson)
          .toList(),
    );
  }

  SalesProfitReport toEntity() {
    return SalesProfitReport(
      transactionCount: transactionCount,
      quantitySold: quantitySold,
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: totalProfit,
      profitMarginPercent: profitMarginPercent,
      rows: rows.map((row) => row.toEntity()).toList(),
    );
  }
}
