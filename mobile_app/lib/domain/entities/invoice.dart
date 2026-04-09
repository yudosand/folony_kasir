class Invoice {
  const Invoice({
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
  final InvoiceStore store;
  final InvoiceCashier cashier;
  final InvoicePayment payment;
  final InvoiceMemberPoints memberPoints;
  final InvoiceTotals totals;
  final List<InvoiceItem> items;
  final DateTime? issuedAt;
}

class InvoiceStore {
  const InvoiceStore({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.invoiceFooter,
    this.logoUrl,
  });

  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? invoiceFooter;
  final String? logoUrl;
}

class InvoiceCashier {
  const InvoiceCashier({
    required this.name,
    required this.email,
  });

  final String? name;
  final String? email;
}

class InvoicePayment {
  const InvoicePayment({
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
}

class InvoiceTotals {
  const InvoiceTotals({
    required this.itemCount,
    required this.subtotal,
    required this.memberPointsValueAmount,
    required this.grandTotal,
  });

  final int itemCount;
  final double subtotal;
  final double memberPointsValueAmount;
  final double grandTotal;
}

class InvoiceMemberPoints {
  const InvoiceMemberPoints({
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
}

class InvoiceItem {
  const InvoiceItem({
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
}
