import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/app/providers.dart';
import 'package:folony_kasir_mobile/domain/entities/invoice.dart';
import 'package:folony_kasir_mobile/domain/entities/member_point_member.dart';
import 'package:folony_kasir_mobile/domain/entities/member_point_usage.dart';
import 'package:folony_kasir_mobile/domain/entities/transaction_detail.dart';
import 'package:folony_kasir_mobile/domain/entities/transaction_input_item.dart';
import 'package:folony_kasir_mobile/domain/entities/transaction_summary.dart';
import 'package:folony_kasir_mobile/domain/repositories/member_point_repository.dart';
import 'package:folony_kasir_mobile/domain/repositories/transaction_repository.dart';
import 'package:folony_kasir_mobile/domain/usecases/create_transaction_use_case.dart';
import 'package:folony_kasir_mobile/domain/usecases/get_member_point_member_use_case.dart';
import 'package:folony_kasir_mobile/presentation/cart/controllers/checkout_controller.dart';

void main() {
  group('CheckoutController', () {
    late FakeTransactionRepository transactionRepository;
    late FakeMemberPointRepository memberPointRepository;
    late ProviderContainer container;

    setUp(() {
      transactionRepository = FakeTransactionRepository();
      memberPointRepository = FakeMemberPointRepository();
      container = ProviderContainer(
        overrides: [
          createTransactionUseCaseProvider.overrideWithValue(
            CreateTransactionUseCase(transactionRepository),
          ),
          getMemberPointMemberUseCaseProvider.overrideWithValue(
            GetMemberPointMemberUseCase(memberPointRepository),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('lookup member and points reduce payable total', () async {
      final notifier = container.read(checkoutControllerProvider.notifier);

      notifier.setMemberIdInput('11');
      await notifier.lookupMember(subtotal: 50000);
      notifier.setPointsUsedInput('10000', subtotal: 50000);

      final preview = notifier.buildPreview(50000);
      final state = container.read(checkoutControllerProvider);

      expect(state.selectedMember?.id, 11);
      expect(preview.originalTotal, 50000);
      expect(preview.memberPointsUsed, 10000);
      expect(preview.total, 40000);
    });

    test('submit checkout forwards member id and points used', () async {
      final notifier = container.read(checkoutControllerProvider.notifier);

      notifier.setMemberIdInput('11');
      await notifier.lookupMember(subtotal: 50000);
      notifier.setPointsUsedInput('10000', subtotal: 50000);
      notifier.setCashAmountInput('40000', subtotal: 50000);

      final result = await notifier.submitCheckout(
        items: const [
          TransactionInputItem(
            productId: 1,
            name: 'Produk Test',
            quantity: 1,
            unitPrice: 50000,
          ),
        ],
        subtotal: 50000,
      );

      expect(result, isNotNull);
      expect(transactionRepository.lastMemberId, 11);
      expect(transactionRepository.lastPointsUsed, 10000);
      expect(transactionRepository.lastCashAmount, 40000);
    });

    test('full member points hide additional payment need', () async {
      final notifier = container.read(checkoutControllerProvider.notifier);

      notifier.setMemberIdInput('11');
      await notifier.lookupMember(subtotal: 20000);
      notifier.setPointsUsedInput('20000', subtotal: 20000);

      final preview = notifier.buildPreview(20000);

      expect(preview.total, 0);
      expect(preview.isFullyPaidByPoints, isTrue);
      expect(preview.requiresAdditionalPayment, isFalse);
    });
  });
}

class FakeTransactionRepository implements TransactionRepository {
  int? lastMemberId;
  int? lastPointsUsed;
  double? lastCashAmount;

  @override
  Future<TransactionDetail> createTransaction({
    required List<TransactionInputItem> items,
    required String paymentMethod,
    required double cashAmount,
    required double nonCashAmount,
    int? memberId,
    int? pointsUsed,
  }) async {
    lastMemberId = memberId;
    lastPointsUsed = pointsUsed;
    lastCashAmount = cashAmount;

    return TransactionDetail(
      id: 1,
      invoiceNumber: 'INV202604060001',
      paymentMethod: paymentMethod,
      paymentStatus: 'paid',
      itemCount: 1,
      subtotal: 50000,
      grandTotal: 40000,
      cashAmount: cashAmount,
      nonCashAmount: nonCashAmount,
      amountPaid: cashAmount + nonCashAmount,
      changeAmount: 0,
      dueAmount: 0,
      memberPoints: const MemberPointUsage(
        memberId: 11,
        memberName: 'Member Test',
        pointsBefore: 20000,
        pointsUsed: 10000,
        pointsAfter: 10000,
        valueAmount: 10000,
        status: 'deducted',
      ),
      items: const [],
    );
  }

  @override
  Future<Invoice> getInvoice(int transactionId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionSummary>> getTransactions({
    int perPage = 100,
    int page = 1,
    String? dateFrom,
    String? dateTo,
  }) {
    throw UnimplementedError();
  }
}

class FakeMemberPointRepository implements MemberPointRepository {
  @override
  Future<MemberPointMember> getMemberById(int memberId) async {
    return const MemberPointMember(
      id: 11,
      name: 'Member Test',
      points: 20000,
    );
  }
}
