import '../../domain/entities/transaction_detail.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/transaction_summary.dart';
import 'member_point_dto.dart';

class TransactionDto {
  const TransactionDto({
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
  final MemberPointUsageDto memberPoints;
  final List<TransactionItemDto> items;
  final DateTime? createdAt;

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      invoiceNumber: json['invoice_number'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      cashAmount: (json['cash_amount'] as num?)?.toDouble() ?? 0,
      nonCashAmount: (json['non_cash_amount'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0,
      memberPoints: MemberPointUsageDto.fromJson(
        json['member_points'] is Map<String, dynamic>
            ? json['member_points'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TransactionItemDto.fromJson)
          .toList(),
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  TransactionSummary toSummary() {
    return TransactionSummary(
      id: id,
      invoiceNumber: invoiceNumber,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      itemCount: itemCount,
      grandTotal: grandTotal,
      amountPaid: amountPaid,
      memberPointValueAmount: memberPoints.valueAmount,
      changeAmount: changeAmount,
      dueAmount: dueAmount,
      createdAt: createdAt,
    );
  }

  TransactionDetail toDetail() {
    return TransactionDetail(
      id: id,
      invoiceNumber: invoiceNumber,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      itemCount: itemCount,
      subtotal: subtotal,
      grandTotal: grandTotal,
      cashAmount: cashAmount,
      nonCashAmount: nonCashAmount,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      dueAmount: dueAmount,
      memberPoints: memberPoints.toEntity(),
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
    );
  }
}

class TransactionItemDto {
  const TransactionItemDto({
    required this.id,
    required this.productId,
    required this.isManual,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.lineSubtotal,
  });

  final int id;
  final int? productId;
  final bool isManual;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double lineSubtotal;

  factory TransactionItemDto.fromJson(Map<String, dynamic> json) {
    return TransactionItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt(),
      isManual: json['is_manual'] as bool? ?? false,
      productName: json['product_name_snapshot'] as String? ??
          json['product_name'] as String? ??
          '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sellingPrice: (json['selling_price_snapshot'] as num?)?.toDouble() ??
          (json['selling_price'] as num?)?.toDouble() ??
          0,
      lineSubtotal: (json['line_subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  TransactionItem toEntity() {
    return TransactionItem(
      id: id,
      productId: productId,
      isManual: isManual,
      productName: productName,
      quantity: quantity,
      sellingPrice: sellingPrice,
      lineSubtotal: lineSubtotal,
    );
  }
}
