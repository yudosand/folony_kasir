class TransactionSummary {
  const TransactionSummary({
    required this.id,
    required this.invoiceNumber,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.itemCount,
    required this.grandTotal,
    required this.amountPaid,
    required this.memberPointValueAmount,
    required this.changeAmount,
    required this.dueAmount,
    this.createdAt,
  });

  final int id;
  final String invoiceNumber;
  final String paymentMethod;
  final String paymentStatus;
  final int itemCount;
  final double grandTotal;
  final double amountPaid;
  final double memberPointValueAmount;
  final double changeAmount;
  final double dueAmount;
  final DateTime? createdAt;
}
