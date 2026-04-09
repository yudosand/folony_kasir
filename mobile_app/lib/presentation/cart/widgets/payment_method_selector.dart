import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/payment_method_option.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PaymentMethodOption value;
  final ValueChanged<PaymentMethodOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethodOption.values.map((method) {
        final isSelected = value == method;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onChanged(method),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _descriptionFor(method),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _descriptionFor(PaymentMethodOption method) {
    switch (method) {
      case PaymentMethodOption.cash:
        return 'Hitung uang dibayar dan kembalian secara otomatis.';
      case PaymentMethodOption.nonCash:
        return 'Cocok untuk QRIS, transfer, kartu, atau e-wallet.';
      case PaymentMethodOption.split:
        return 'Gabungkan pembayaran tunai dan non tunai dalam satu transaksi.';
    }
  }
}
