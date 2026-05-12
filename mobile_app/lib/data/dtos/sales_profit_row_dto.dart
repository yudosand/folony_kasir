import '../../domain/entities/sales_profit_row.dart';

class SalesProfitRowDto {
  const SalesProfitRowDto({
    required this.id,
    required this.transactionId,
    required this.invoiceNumber,
    required this.productName,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.cashierName,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.totalCost,
    required this.totalSelling,
    required this.totalProfit,
    this.transactionDate,
  });

  final int id;
  final int transactionId;
  final String invoiceNumber;
  final String productName;
  final String paymentMethod;
  final String paymentStatus;
  final String cashierName;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final double totalCost;
  final double totalSelling;
  final double totalProfit;
  final DateTime? transactionDate;

  factory SalesProfitRowDto.fromJson(Map<String, dynamic> json) {
    return SalesProfitRowDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      transactionId: (json['transaction_id'] as num?)?.toInt() ?? 0,
      invoiceNumber: json['invoice_number'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      cashierName: json['cashier_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      totalSelling: (json['total_selling'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0,
      transactionDate: json['transaction_date'] is String
          ? DateTime.tryParse(json['transaction_date'] as String)
          : null,
    );
  }

  SalesProfitRow toEntity() {
    return SalesProfitRow(
      id: id,
      transactionId: transactionId,
      invoiceNumber: invoiceNumber,
      productName: productName,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      cashierName: cashierName,
      quantity: quantity,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      totalCost: totalCost,
      totalSelling: totalSelling,
      totalProfit: totalProfit,
      transactionDate: transactionDate,
    );
  }
}
