import 'transaction_item.dart';
import 'member_point_usage.dart';

class TransactionDetail {
  const TransactionDetail({
    required this.id,
    required this.invoiceNumber,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.itemCount,
    required this.subtotal,
    required this.grandTotal,
    required this.cashAmount,
    required this.nonCashAmount,
    required this.amountPaid,
    required this.changeAmount,
    required this.dueAmount,
    required this.memberPoints,
    required this.items,
    this.createdAt,
  });

  final int id;
  final String invoiceNumber;
  final String paymentMethod;
  final String paymentStatus;
  final int itemCount;
  final double subtotal;
  final double grandTotal;
  final double cashAmount;
  final double nonCashAmount;
  final double amountPaid;
  final double changeAmount;
  final double dueAmount;
  final MemberPointUsage memberPoints;
  final List<TransactionItem> items;
  final DateTime? createdAt;
}
