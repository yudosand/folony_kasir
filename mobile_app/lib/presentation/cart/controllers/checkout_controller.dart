import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../domain/entities/member_point_member.dart';
import '../../../domain/entities/payment_method_option.dart';
import '../../../domain/entities/transaction_detail.dart';
import '../../../domain/entities/transaction_input_item.dart';

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setPaymentMethod(
    PaymentMethodOption method, {
    required double subtotal,
  }) {
    final total = payableTotal(subtotal);

    switch (method) {
      case PaymentMethodOption.cash:
        state = state.copyWith(
          paymentMethod: method,
          nonCashAmountInput: '',
          errorMessage: null,
        );
        return;
      case PaymentMethodOption.nonCash:
        state = state.copyWith(
          paymentMethod: method,
          cashAmountInput: '',
          nonCashAmountInput: _formatAmount(total),
          errorMessage: null,
        );
        return;
      case PaymentMethodOption.split:
        final currentCash = _parseAmount(state.cashAmountInput);
        final remaining = (total - currentCash).clamp(0.0, total);
        state = state.copyWith(
          paymentMethod: method,
          nonCashAmountInput: _formatAmount(remaining),
          errorMessage: null,
        );
        return;
    }
  }

  void setCashAmountInput(
    String value, {
    required double subtotal,
  }) {
    final total = payableTotal(subtotal);
    final nextCash = _parseAmount(value);

    if (state.paymentMethod == PaymentMethodOption.split) {
      final remaining = (total - nextCash).clamp(0.0, total);
      state = state.copyWith(
        cashAmountInput: value,
        nonCashAmountInput: _formatAmount(remaining),
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(cashAmountInput: value, errorMessage: null);
  }

  void setNonCashAmountInput(String value) {
    state = state.copyWith(nonCashAmountInput: value, errorMessage: null);
  }

  void setMemberIdInput(String value) {
    final currentMember = state.selectedMember;
    final shouldClearSelectedMember =
        currentMember != null && currentMember.id.toString() != value.trim();

    state = state.copyWith(
      memberIdInput: value,
      pointsUsedInput: shouldClearSelectedMember ? '' : null,
      clearSelectedMember: shouldClearSelectedMember,
      errorMessage: null,
    );
  }

  Future<void> lookupMember({required double subtotal}) async {
    final memberId = int.tryParse(state.memberIdInput.trim());
    if (memberId == null || memberId <= 0) {
      state = state.copyWith(
        errorMessage: 'ID member belum valid ya.',
      );
      return;
    }

    state = state.copyWith(
      isLookingUpMember: true,
      errorMessage: null,
    );

    try {
      final member =
          await ref.read(getMemberPointMemberUseCaseProvider).call(memberId);
      state = state.copyWith(
        isLookingUpMember: false,
        selectedMember: member,
        errorMessage: null,
      );
      _syncPaymentByCurrentMethod(subtotal);
    } catch (error) {
      final message = error is ApiException ? error.message : error.toString();
      state = state.copyWith(
        isLookingUpMember: false,
        pointsUsedInput: '',
        clearSelectedMember: true,
        errorMessage: message,
      );
      _syncPaymentByCurrentMethod(subtotal);
    }
  }

  void clearMember({required double subtotal}) {
    state = state.copyWith(
      memberIdInput: '',
      pointsUsedInput: '',
      clearSelectedMember: true,
      errorMessage: null,
    );
    _syncPaymentByCurrentMethod(subtotal);
  }

  void setPointsUsedInput(
    String value, {
    required double subtotal,
  }) {
    final selectedMember = state.selectedMember;
    if (selectedMember == null) {
      state = state.copyWith(
        pointsUsedInput: '',
        errorMessage: 'Member wajib dipilih dulu ya.',
      );
      return;
    }

    final raw = _parseAmount(value).round();
    final maxAllowed = selectedMember.points < subtotal.round()
        ? selectedMember.points
        : subtotal.round();
    final normalized = raw.clamp(0, maxAllowed);

    state = state.copyWith(
      pointsUsedInput: raw == normalized ? value : _formatAmount(normalized.toDouble()),
      errorMessage: null,
    );
    _syncPaymentByCurrentMethod(subtotal);
  }

  CheckoutPreview buildPreview(double subtotal) {
    final total = payableTotal(subtotal);
    final cashAmount = _parseAmount(state.cashAmountInput);
    final effectiveSplitCash = _effectiveSplitCash(total);
    final nonCashAmount = _derivedNonCashAmount(total);
    final memberPointsUsed = effectivePointsUsed(subtotal);

    switch (state.paymentMethod) {
      case PaymentMethodOption.cash:
        return _buildPaymentPreview(
          originalTotal: subtotal,
          total: total,
          memberPointsUsed: memberPointsUsed,
          amountPaid: cashAmount,
          cashPortion: cashAmount,
          nonCashPortion: 0,
          allowChange: true,
        );
      case PaymentMethodOption.nonCash:
        return CheckoutPreview(
          originalTotal: subtotal,
          total: total,
          memberPointsUsed: memberPointsUsed,
          amountPaid: total,
          changeAmount: 0,
          dueAmount: 0,
          paymentStatus: 'paid',
          cashPortion: 0,
          nonCashPortion: total,
        );
      case PaymentMethodOption.split:
        return CheckoutPreview(
          originalTotal: subtotal,
          total: total,
          memberPointsUsed: memberPointsUsed,
          amountPaid: effectiveSplitCash + nonCashAmount,
          changeAmount: 0,
          dueAmount: 0,
          paymentStatus: 'paid',
          cashPortion: effectiveSplitCash,
          nonCashPortion: nonCashAmount,
        );
    }
  }

  Future<TransactionDetail?> submitCheckout({
    required List<TransactionInputItem> items,
    required double subtotal,
  }) async {
    if (items.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Keranjang masih kosong. Tambahkan produk dulu ya.',
      );
      return null;
    }

    final total = payableTotal(subtotal);
    final cashAmount = _effectiveCashAmount(total);
    final nonCashAmount = _effectiveNonCashAmount(total);
    final selectedMember = state.selectedMember;
    final pointsUsed = effectivePointsUsed(subtotal);

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );

    try {
      final result = await ref.read(createTransactionUseCaseProvider).call(
            items: items,
            paymentMethod: state.paymentMethod.backendValue,
            cashAmount: cashAmount,
            nonCashAmount: nonCashAmount,
            memberId:
                selectedMember != null && pointsUsed > 0 ? selectedMember.id : null,
            pointsUsed: pointsUsed > 0 ? pointsUsed : null,
          );

      state = state.copyWith(
        isSubmitting: false,
        lastResult: result,
      );

      return result;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const CheckoutState();
  }

  double payableTotal(double subtotal) {
    final pointsValue = effectivePointsUsed(subtotal).toDouble();
    return (subtotal - pointsValue).clamp(0.0, subtotal);
  }

  int effectivePointsUsed(double subtotal) {
    final selectedMember = state.selectedMember;
    if (selectedMember == null) {
      return 0;
    }

    final raw = _parseAmount(state.pointsUsedInput).round();
    if (raw <= 0) {
      return 0;
    }

    final maxAllowed = selectedMember.points < subtotal.round()
        ? selectedMember.points
        : subtotal.round();

    return raw.clamp(0, maxAllowed);
  }

  void _syncPaymentByCurrentMethod(double subtotal) {
    final total = payableTotal(subtotal);

    switch (state.paymentMethod) {
      case PaymentMethodOption.nonCash:
        state = state.copyWith(
          nonCashAmountInput: _formatAmount(total),
        );
        return;
      case PaymentMethodOption.split:
        final currentCash = _parseAmount(state.cashAmountInput);
        final remaining = (total - currentCash).clamp(0.0, total);
        state = state.copyWith(
          nonCashAmountInput: _formatAmount(remaining),
        );
        return;
      case PaymentMethodOption.cash:
        return;
    }
  }

  double _effectiveCashAmount(double total) {
    switch (state.paymentMethod) {
      case PaymentMethodOption.cash:
        return _parseAmount(state.cashAmountInput);
      case PaymentMethodOption.split:
        return _effectiveSplitCash(total);
      case PaymentMethodOption.nonCash:
        return 0;
    }
  }

  double _effectiveNonCashAmount(double total) {
    switch (state.paymentMethod) {
      case PaymentMethodOption.nonCash:
        return total;
      case PaymentMethodOption.split:
        return _derivedNonCashAmount(total);
      case PaymentMethodOption.cash:
        return 0;
    }
  }

  double _derivedNonCashAmount(double total) {
    switch (state.paymentMethod) {
      case PaymentMethodOption.nonCash:
        return total;
      case PaymentMethodOption.split:
        final remaining = total - _effectiveSplitCash(total);
        return remaining > 0 ? remaining : 0;
      case PaymentMethodOption.cash:
        return 0;
    }
  }

  double _effectiveSplitCash(double total) {
    final inputCash = _parseAmount(state.cashAmountInput);
    if (inputCash <= 0) {
      return 0;
    }
    return inputCash > total ? total : inputCash;
  }

  CheckoutPreview _buildPaymentPreview({
    required double originalTotal,
    required double total,
    required int memberPointsUsed,
    required double amountPaid,
    required double cashPortion,
    required double nonCashPortion,
    required bool allowChange,
  }) {
    final difference = amountPaid - total;
    final changeAmount =
        allowChange && difference > 0 ? difference.toDouble() : 0.0;
    final dueAmount = difference < 0 ? difference.abs().toDouble() : 0.0;

    return CheckoutPreview(
      originalTotal: originalTotal,
      total: total,
      memberPointsUsed: memberPointsUsed,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      dueAmount: dueAmount,
      paymentStatus: dueAmount > 0 ? 'partial' : 'paid',
      cashPortion: cashPortion,
      nonCashPortion: nonCashPortion,
    );
  }

  double _parseAmount(String input) {
    return RupiahFormatter.parse(input);
  }

  String _formatAmount(double value) {
    if (value <= 0) {
      return '';
    }
    return RupiahFormatter.formatInput(value.round());
  }
}

class CheckoutState {
  const CheckoutState({
    this.paymentMethod = PaymentMethodOption.cash,
    this.cashAmountInput = '',
    this.nonCashAmountInput = '',
    this.memberIdInput = '',
    this.pointsUsedInput = '',
    this.selectedMember,
    this.isLookingUpMember = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.lastResult,
  });

  final PaymentMethodOption paymentMethod;
  final String cashAmountInput;
  final String nonCashAmountInput;
  final String memberIdInput;
  final String pointsUsedInput;
  final MemberPointMember? selectedMember;
  final bool isLookingUpMember;
  final bool isSubmitting;
  final String? errorMessage;
  final TransactionDetail? lastResult;

  CheckoutState copyWith({
    PaymentMethodOption? paymentMethod,
    String? cashAmountInput,
    String? nonCashAmountInput,
    String? memberIdInput,
    String? pointsUsedInput,
    MemberPointMember? selectedMember,
    bool clearSelectedMember = false,
    bool? isLookingUpMember,
    bool? isSubmitting,
    String? errorMessage,
    TransactionDetail? lastResult,
  }) {
    return CheckoutState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashAmountInput: cashAmountInput ?? this.cashAmountInput,
      nonCashAmountInput: nonCashAmountInput ?? this.nonCashAmountInput,
      memberIdInput: memberIdInput ?? this.memberIdInput,
      pointsUsedInput: pointsUsedInput ?? this.pointsUsedInput,
      selectedMember: clearSelectedMember
          ? null
          : selectedMember ?? this.selectedMember,
      isLookingUpMember: isLookingUpMember ?? this.isLookingUpMember,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

class CheckoutPreview {
  const CheckoutPreview({
    required this.originalTotal,
    required this.total,
    required this.memberPointsUsed,
    required this.amountPaid,
    required this.changeAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.cashPortion,
    required this.nonCashPortion,
  });

  final double originalTotal;
  final double total;
  final int memberPointsUsed;
  final double amountPaid;
  final double changeAmount;
  final double dueAmount;
  final String paymentStatus;
  final double cashPortion;
  final double nonCashPortion;

  double get memberPointsValueAmount => memberPointsUsed.toDouble();

  bool get isFullyPaidByPoints => memberPointsUsed > 0 && total <= 0;

  bool get requiresAdditionalPayment => total > 0;
}
