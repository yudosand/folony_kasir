import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/entities/payment_method_option.dart';
import '../../../domain/entities/transaction_input_item.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../../transactions/controllers/transaction_list_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_summary_card.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  late final TextEditingController _cashController;
  late final TextEditingController _nonCashController;
  late final TextEditingController _memberIdController;
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    final checkoutState = ref.read(checkoutControllerProvider);
    _cashController = TextEditingController(text: checkoutState.cashAmountInput);
    _nonCashController =
        TextEditingController(text: checkoutState.nonCashAmountInput);
    _memberIdController =
        TextEditingController(text: checkoutState.memberIdInput);
    _pointsController =
        TextEditingController(text: checkoutState.pointsUsedInput);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _nonCashController.dispose();
    _memberIdController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);
    _syncPaymentControllers(
      checkoutState: checkoutState,
      subtotal: cartState.subtotal,
    );
    _syncMemberControllers(checkoutState: checkoutState);
    final preview = checkoutNotifier.buildPreview(cartState.subtotal);
    final showPaymentMethodSection = preview.requiresAdditionalPayment;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            if (cartState.isEmpty)
              _EmptyCartState(
                onBackToProducts: () => context.pop(),
              )
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                children: [
                  Text(
                    'Ringkasan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (var index = 0; index < cartState.items.length; index++) ...[
                          CartItemTile(
                            item: cartState.items[index],
                            onIncrement: () => ref
                                .read(cartControllerProvider.notifier)
                                .incrementItem(cartState.items[index].productId),
                            onDecrement: () => ref
                                .read(cartControllerProvider.notifier)
                                .decrementItem(cartState.items[index].productId),
                            onRemove: () => ref
                                .read(cartControllerProvider.notifier)
                                .removeItem(cartState.items[index].productId),
                          ),
                          if (index < cartState.items.length - 1)
                            const Divider(height: 18, color: AppColors.border),
                        ],
                        const Divider(height: 24, color: AppColors.border),
                        Row(
                          children: [
                            Text(
                              'Total Produk',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const Spacer(),
                            Text(
                              RupiahFormatter.format(cartState.subtotal),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gunakan Member',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _buildMemberSection(
                    context: context,
                    checkoutState: checkoutState,
                    subtotal: cartState.subtotal,
                    preview: preview,
                  ),
                  if (showPaymentMethodSection) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Dibayar Menggunakan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    PaymentMethodSelector(
                      value: checkoutState.paymentMethod,
                      onChanged: (method) => checkoutNotifier.setPaymentMethod(
                        method,
                        subtotal: cartState.subtotal,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else
                    const SizedBox(height: 16),
                  PaymentSummaryCard(
                    preview: preview,
                    paymentMethod: checkoutState.paymentMethod,
                    paymentInput: showPaymentMethodSection
                        ? _buildPaymentInputSection(
                            checkoutState: checkoutState,
                            subtotal: cartState.subtotal,
                          )
                        : null,
                  ),
                  if (checkoutState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      checkoutState.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.danger,
                          ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Simpan Transaksi',
                    isLoading: checkoutState.isSubmitting,
                    onPressed: () async {
                      checkoutNotifier.setCashAmountInput(
                        _cashController.text,
                        subtotal: cartState.subtotal,
                      );
                      checkoutNotifier.setNonCashAmountInput(_nonCashController.text);

                      final result = await checkoutNotifier.submitCheckout(
                        items: cartState.items
                            .map(
                              (item) => TransactionInputItem(
                                productId: item.productId,
                                name: item.productName,
                                quantity: item.quantity,
                                unitPrice: item.sellingPrice,
                                availableStock: item.stock,
                                imageUrl: item.imageUrl,
                              ),
                            )
                            .toList(),
                        subtotal: cartState.subtotal,
                      );

                      if (result == null || !context.mounted) {
                        return;
                      }

                      ref.read(cartControllerProvider.notifier).clear();
                      checkoutNotifier.reset();
                      _cashController.clear();
                      _nonCashController.clear();
                      _memberIdController.clear();
                      _pointsController.clear();
                      ref.invalidate(transactionListControllerProvider);

                      context.pushReplacement(
                        AppRoutes.transactionInvoice(result.id),
                      );
                    },
                  ),
                ],
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DemoScreenHeader(
                title: 'Checkout',
                height: 50,
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0x12000000),
                  ),
                ),
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                leading: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncPaymentControllers({
    required CheckoutState checkoutState,
    required double subtotal,
  }) {
    if (_cashController.text != checkoutState.cashAmountInput) {
      _cashController.value = _cashController.value.copyWith(
        text: checkoutState.cashAmountInput,
        selection: TextSelection.collapsed(
          offset: checkoutState.cashAmountInput.length,
        ),
        composing: TextRange.empty,
      );
    }

    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);
    final payableTotal = checkoutNotifier.payableTotal(subtotal);
    final desiredNonCashText = checkoutState.paymentMethod == PaymentMethodOption.cash
        ? checkoutState.nonCashAmountInput
        : RupiahFormatter.formatInput(
            (checkoutState.paymentMethod == PaymentMethodOption.nonCash
                    ? payableTotal
                    : (payableTotal -
                        RupiahFormatter.parse(checkoutState.cashAmountInput)))
                .clamp(0.0, payableTotal)
                .round(),
          );

    if (_nonCashController.text != desiredNonCashText) {
      _nonCashController.value = _nonCashController.value.copyWith(
        text: desiredNonCashText,
        selection: TextSelection.collapsed(
          offset: desiredNonCashText.length,
        ),
        composing: TextRange.empty,
      );
    }
  }

  void _syncMemberControllers({
    required CheckoutState checkoutState,
  }) {
    if (_memberIdController.text != checkoutState.memberIdInput) {
      _memberIdController.value = _memberIdController.value.copyWith(
        text: checkoutState.memberIdInput,
        selection: TextSelection.collapsed(
          offset: checkoutState.memberIdInput.length,
        ),
        composing: TextRange.empty,
      );
    }

    if (_pointsController.text != checkoutState.pointsUsedInput) {
      _pointsController.value = _pointsController.value.copyWith(
        text: checkoutState.pointsUsedInput,
        selection: TextSelection.collapsed(
          offset: checkoutState.pointsUsedInput.length,
        ),
        composing: TextRange.empty,
      );
    }
  }

  Widget _buildMemberSection({
    required BuildContext context,
    required CheckoutState checkoutState,
    required double subtotal,
    required CheckoutPreview preview,
  }) {
    final selectedMember = checkoutState.selectedMember;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _memberIdController,
            label: 'ID Member',
            hintText: 'Masukkan ID member Foloni App',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => ref
                .read(checkoutControllerProvider.notifier)
                .setMemberIdInput(value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: checkoutState.isLookingUpMember
                      ? null
                      : () => ref
                          .read(checkoutControllerProvider.notifier)
                          .lookupMember(subtotal: subtotal),
                  icon: checkoutState.isLookingUpMember
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    checkoutState.isLookingUpMember ? 'Mencari...' : 'Cek Member',
                  ),
                ),
              ),
              if (selectedMember != null) ...[
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => ref
                      .read(checkoutControllerProvider.notifier)
                      .clearMember(subtotal: subtotal),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ],
          ),
          if (selectedMember != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMember.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID Member: ${selectedMember.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Poin tersedia: ${RupiahFormatter.format(selectedMember.points.toDouble())}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _pointsController,
              label: 'Poin Digunakan',
              hintText: 'Masukkan jumlah poin yang dipakai',
              prefixIcon: Icons.stars_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const RupiahInputFormatter(),
              ],
              onChanged: (value) => ref
                  .read(checkoutControllerProvider.notifier)
                  .setPointsUsedInput(
                    value,
                    subtotal: subtotal,
                  ),
            ),
            if (preview.memberPointsUsed > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Potongan member: ${RupiahFormatter.format(preview.memberPointsValueAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget? _buildPaymentInputSection({
    required CheckoutState checkoutState,
    required double subtotal,
  }) {
    if (checkoutState.paymentMethod == PaymentMethodOption.nonCash) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _cashController,
          label: checkoutState.paymentMethod == PaymentMethodOption.cash
              ? 'Uang Dibayarkan'
              : 'Uang Tunai',
          hintText: checkoutState.paymentMethod == PaymentMethodOption.cash
              ? 'Masukkan nominal pembayaran'
              : 'Masukkan nominal tunai',
          prefixIcon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const RupiahInputFormatter(),
          ],
          onChanged: (value) =>
              ref.read(checkoutControllerProvider.notifier).setCashAmountInput(
                    value,
                    subtotal: subtotal,
                  ),
          onSubmitted: (value) =>
              ref.read(checkoutControllerProvider.notifier).setCashAmountInput(
                    value,
                    subtotal: subtotal,
                  ),
        ),
        if (checkoutState.paymentMethod == PaymentMethodOption.split) ...[
          const SizedBox(height: 14),
          AppTextField(
            controller: _nonCashController,
            label: 'Sisa Dibayar Non Tunai',
            hintText: 'Otomatis mengikuti sisa pembayaran',
            prefixIcon: Icons.qr_code_2_outlined,
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
        ],
      ],
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState({
    required this.onBackToProducts,
  });

  final VoidCallback onBackToProducts;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 52,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 14),
              Text(
                'Keranjang masih kosong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan produk dari daftar produk sebelum melakukan checkout.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Kembali ke Produk',
                onPressed: onBackToProducts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
