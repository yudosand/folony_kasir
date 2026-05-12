import '../../domain/entities/stock_bookkeeping_report.dart';
import 'stock_bookkeeping_row_dto.dart';

class StockBookkeepingReportDto {
  const StockBookkeepingReportDto({
    required this.productCount,
    required this.needsRestockCount,
    required this.outOfStockCount,
    required this.lowStockCount,
    required this.rows,
  });

  final int productCount;
  final int needsRestockCount;
  final int outOfStockCount;
  final int lowStockCount;
  final List<StockBookkeepingRowDto> rows;

  factory StockBookkeepingReportDto.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    final rawRows = json['rows'] as List<dynamic>? ?? const [];

    return StockBookkeepingReportDto(
      productCount: (summary['product_count'] as num?)?.toInt() ?? 0,
      needsRestockCount:
          (summary['needs_restock_count'] as num?)?.toInt() ?? 0,
      outOfStockCount: (summary['out_of_stock_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (summary['low_stock_count'] as num?)?.toInt() ?? 0,
      rows: rawRows
          .whereType<Map<String, dynamic>>()
          .map(StockBookkeepingRowDto.fromJson)
          .toList(),
    );
  }

  StockBookkeepingReport toEntity() {
    return StockBookkeepingReport(
      productCount: productCount,
      needsRestockCount: needsRestockCount,
      outOfStockCount: outOfStockCount,
      lowStockCount: lowStockCount,
      rows: rows.map((row) => row.toEntity()).toList(),
    );
  }
}
