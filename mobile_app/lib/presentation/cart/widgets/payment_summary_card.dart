import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/payment_display.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../domain/entities/payment_method_option.dart';
import '../controllers/checkout_controller.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.preview,
    required this.paymentMethod,
    this.paymentInput,
  });

  final CheckoutPreview preview;
  final PaymentMethodOption paymentMethod;
  final Widget? paymentInput;

  @override
  Widget build(BuildContext context) {
    final showPaymentBreakdown = preview.requiresAdditionalPayment;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Tagihan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total Produk',
            value: RupiahFormatter.format(preview.originalTotal),
          ),
          if (preview.memberPointsUsed > 0)
            _SummaryRow(
              label: 'Potongan Poin Member',
              value: '-${RupiahFormatter.format(preview.memberPointsValueAmount)}',
            ),
          _SummaryRow(
            label: 'Total',
            value: RupiahFormatter.format(preview.total),
          ),
          if (showPaymentBreakdown && paymentInput != null) ...[
            const SizedBox(height: 8),
            paymentInput!,
          ],
          if (showPaymentBreakdown) ...[
            const SizedBox(height: 14),
            ..._buildSummaryRows(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSummaryRows(BuildContext context) {
    switch (paymentMethod) {
      case PaymentMethodOption.cash:
        return [
          _SummaryRow(
            label: 'Total Dibayar',
            value: RupiahFormatter.format(preview.amountPaid),
          ),
          const SizedBox(height: 10),
          _StatusCard(
            label: preview.dueAmount > 0 ? 'Kurang Bayar' : 'Kembalian',
            value: RupiahFormatter.format(
              preview.dueAmount > 0 ? preview.dueAmount : preview.changeAmount,
            ),
            subtitle: PaymentDisplay.paymentStatus(preview.paymentStatus),
            isDue: preview.dueAmount > 0,
          ),
        ];
      case PaymentMethodOption.nonCash:
        return [
          _SummaryRow(
            label: 'Total Dibayar',
            value: RupiahFormatter.format(preview.amountPaid),
          ),
        ];
      case PaymentMethodOption.split:
        return [
          _SummaryRow(
            label: 'Dibayar Tunai',
            value: RupiahFormatter.format(preview.cashPortion),
          ),
          _SummaryRow(
            label: 'Dibayar Non Tunai',
            value: RupiahFormatter.format(preview.nonCashPortion),
          ),
          _SummaryRow(
            label: 'Total Dibayar',
            value: RupiahFormatter.format(preview.amountPaid),
          ),
        ];
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.isDue,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool isDue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDue ? const Color(0xFFFFF2EF) : const Color(0xFFF3FAF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDue ? const Color(0xFFFFD5CC) : const Color(0xFFD5ECDD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
