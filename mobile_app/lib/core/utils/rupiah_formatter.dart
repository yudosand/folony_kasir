import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RupiahFormatter {
  RupiahFormatter._();

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _inputFormatter = NumberFormat.decimalPattern(
    'id_ID',
  );

  static String format(double value) {
    return _currencyFormatter.format(value);
  }

  static String formatInput(num value) {
    return _inputFormatter.format(value);
  }

  static double parse(String input) {
    final digits = digitsOnly(input);
    if (digits.isEmpty) {
      return 0;
    }

    return double.tryParse(digits) ?? 0;
  }

  static String digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = RupiahFormatter.digitsOnly(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = RupiahFormatter.formatInput(int.parse(digits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
