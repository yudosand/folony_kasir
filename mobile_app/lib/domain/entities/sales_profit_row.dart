class SalesProfitRow {
  const SalesProfitRow({
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

  bool get isProfit => totalProfit > 0;
  bool get isBreakEven => totalProfit == 0;
  bool get isLoss => totalProfit < 0;

  String get profitStatusCode {
    if (isProfit) {
      return 'profit';
    }
    if (isLoss) {
      return 'loss';
    }
    return 'break_even';
  }

  String get profitStatusLabel {
    if (isProfit) {
      return 'Untung';
    }
    if (isLoss) {
      return 'Rugi';
    }
    return 'Impas';
  }
}
