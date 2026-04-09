enum PaymentMethodOption {
  cash('cash'),
  nonCash('non_cash'),
  split('split');

  const PaymentMethodOption(this.backendValue);

  final String backendValue;

  String get label {
    switch (this) {
      case PaymentMethodOption.cash:
        return 'Tunai';
      case PaymentMethodOption.nonCash:
        return 'Non Tunai';
      case PaymentMethodOption.split:
        return 'Split';
    }
  }
}
