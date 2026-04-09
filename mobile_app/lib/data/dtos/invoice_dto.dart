import '../../domain/entities/invoice.dart';
import '../../core/utils/media_url_resolver.dart';

class InvoiceDto {
  const InvoiceDto({
    required this.invoiceNumber,
    required this.store,
    required this.cashier,
    required this.payment,
    required this.memberPoints,
    required this.totals,
    required this.items,
    this.issuedAt,
  });

  final String invoiceNumber;
  final InvoiceStoreDto store;
  final InvoiceCashierDto cashier;
  final InvoicePaymentDto payment;
  final InvoiceMemberPointsDto memberPoints;
  final InvoiceTotalsDto totals;
  final List<InvoiceItemDto> items;
  final DateTime? issuedAt;

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDto(
      invoiceNumber: json['invoice_number'] as String? ?? '',
      store: InvoiceStoreDto.fromJson(
        json['store'] is Map<String, dynamic>
            ? json['store'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      cashier: InvoiceCashierDto.fromJson(
        json['cashier'] is Map<String, dynamic>
            ? json['cashier'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      payment: InvoicePaymentDto.fromJson(
        json['payment'] is Map<String, dynamic>
            ? json['payment'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      memberPoints: InvoiceMemberPointsDto.fromJson(
        json['member_points'] is Map<String, dynamic>
            ? json['member_points'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      totals: InvoiceTotalsDto.fromJson(
        json['totals'] is Map<String, dynamic>
            ? json['totals'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(InvoiceItemDto.fromJson)
          .toList(),
      issuedAt: json['issued_at'] is String
          ? DateTime.tryParse(json['issued_at'] as String)
          : null,
    );
  }

  Invoice toEntity() {
    return Invoice(
      invoiceNumber: invoiceNumber,
      store: store.toEntity(),
      cashier: cashier.toEntity(),
      payment: payment.toEntity(),
      memberPoints: memberPoints.toEntity(),
      totals: totals.toEntity(),
      items: items.map((item) => item.toEntity()).toList(),
      issuedAt: issuedAt,
    );
  }
}

class InvoiceStoreDto {
  const InvoiceStoreDto({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.invoiceFooter,
    required this.logoUrl,
  });

  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? invoiceFooter;
  final String? logoUrl;

  factory InvoiceStoreDto.fromJson(Map<String, dynamic> json) {
    return InvoiceStoreDto(
      name: json['name'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      invoiceFooter: json['invoice_footer'] as String?,
      logoUrl: MediaUrlResolver.resolve(json['logo_url'] as String?),
    );
  }

  InvoiceStore toEntity() {
    return InvoiceStore(
      name: name,
      address: address,
      phoneNumber: phoneNumber,
      invoiceFooter: invoiceFooter,
      logoUrl: logoUrl,
    );
  }
}

class InvoiceCashierDto {
  const InvoiceCashierDto({
    required this.name,
    required this.email,
  });

  final String? name;
  final String? email;

  factory InvoiceCashierDto.fromJson(Map<String, dynamic> json) {
    return InvoiceCashierDto(
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  InvoiceCashier toEntity() {
    return InvoiceCashier(
      name: name,
      email: email,
    );
  }
}

class InvoicePaymentDto {
  const InvoicePaymentDto({
    required this.method,
    required this.status,
    required this.cashAmount,
    required this.nonCashAmount,
    required this.amountPaid,
    required this.changeAmount,
    required this.dueAmount,
  });

  final String method;
  final String status;
  final double cashAmount;
  final double nonCashAmount;
  final double amountPaid;
  final double changeAmount;
  final double dueAmount;

  factory InvoicePaymentDto.fromJson(Map<String, dynamic> json) {
    return InvoicePaymentDto(
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      cashAmount: (json['cash_amount'] as num?)?.toDouble() ?? 0,
      nonCashAmount: (json['non_cash_amount'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  InvoicePayment toEntity() {
    return InvoicePayment(
      method: method,
      status: status,
      cashAmount: cashAmount,
      nonCashAmount: nonCashAmount,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      dueAmount: dueAmount,
    );
  }
}

class InvoiceTotalsDto {
  const InvoiceTotalsDto({
    required this.itemCount,
    required this.subtotal,
    required this.memberPointsValueAmount,
    required this.grandTotal,
  });

  final int itemCount;
  final double subtotal;
  final double memberPointsValueAmount;
  final double grandTotal;

  factory InvoiceTotalsDto.fromJson(Map<String, dynamic> json) {
    return InvoiceTotalsDto(
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      memberPointsValueAmount:
          (json['member_points_value_amount'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
    );
  }

  InvoiceTotals toEntity() {
    return InvoiceTotals(
      itemCount: itemCount,
      subtotal: subtotal,
      memberPointsValueAmount: memberPointsValueAmount,
      grandTotal: grandTotal,
    );
  }
}

class InvoiceMemberPointsDto {
  const InvoiceMemberPointsDto({
    required this.memberId,
    required this.memberName,
    required this.pointsBefore,
    required this.pointsUsed,
    required this.pointsAfter,
    required this.valueAmount,
    required this.status,
    this.description,
  });

  final int? memberId;
  final String? memberName;
  final int? pointsBefore;
  final int pointsUsed;
  final int? pointsAfter;
  final double valueAmount;
  final String status;
  final String? description;

  factory InvoiceMemberPointsDto.fromJson(Map<String, dynamic> json) {
    return InvoiceMemberPointsDto(
      memberId: (json['member_id'] as num?)?.toInt(),
      memberName: json['member_name'] as String?,
      pointsBefore: (json['points_before'] as num?)?.toInt(),
      pointsUsed: (json['points_used'] as num?)?.toInt() ?? 0,
      pointsAfter: (json['points_after'] as num?)?.toInt(),
      valueAmount: (json['value_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'none',
      description: json['description'] as String?,
    );
  }

  InvoiceMemberPoints toEntity() {
    return InvoiceMemberPoints(
      memberId: memberId,
      memberName: memberName,
      pointsBefore: pointsBefore,
      pointsUsed: pointsUsed,
      pointsAfter: pointsAfter,
      valueAmount: valueAmount,
      status: status,
      description: description,
    );
  }
}

class InvoiceItemDto {
  const InvoiceItemDto({
    required this.productId,
    required this.isManual,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.lineSubtotal,
  });

  final int? productId;
  final bool isManual;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double lineSubtotal;

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) {
    return InvoiceItemDto(
      productId: (json['product_id'] as num?)?.toInt(),
      isManual: json['is_manual'] as bool? ?? false,
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      lineSubtotal: (json['line_subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  InvoiceItem toEntity() {
    return InvoiceItem(
      productId: productId,
      isManual: isManual,
      productName: productName,
      quantity: quantity,
      sellingPrice: sellingPrice,
      lineSubtotal: lineSubtotal,
    );
  }
}
