class PaymentDisplay {
  PaymentDisplay._();

  static String paymentMethod(String value) {
    switch (value) {
      case 'cash':
        return 'Tunai';
      case 'non_cash':
        return 'Non Tunai';
      case 'split':
        return 'Split';
      default:
        return value;
    }
  }

  static String paymentStatus(String value) {
    switch (value) {
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Parsial';
      default:
        return value;
    }
  }
}
