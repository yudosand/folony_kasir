import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/entities/payment_method_option.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaction_input_item.dart';
import '../../cart/controllers/checkout_controller.dart';
import '../../cart/widgets/payment_method_selector.dart';
import '../../cart/widgets/payment_summary_card.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../../transactions/controllers/transaction_list_controller.dart';
import '../controllers/manual_transaction_controller.dart';

class ManualTransactionPage extends ConsumerStatefulWidget {
  const ManualTransactionPage({super.key});

  @override
  ConsumerState<ManualTransactionPage> createState() =>
      _ManualTransactionPageState();
}

class _ManualTransactionPageState extends ConsumerState<ManualTransactionPage> {
  late final TextEditingController _manualNameController;
  late final TextEditingController _manualQtyController;
  late final TextEditingController _manualPriceController;
  late final TextEditingController _cashController;
  late final TextEditingController _nonCashController;
  late final TextEditingController _memberIdController;
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _manualNameController = TextEditingController();
    _manualQtyController = TextEditingController(text: '1');
    _manualPriceController = TextEditingController();
    _cashController = TextEditingController();
    _nonCashController = TextEditingController();
    final checkoutState = ref.read(checkoutControllerProvider);
    _memberIdController =
        TextEditingController(text: checkoutState.memberIdInput);
    _pointsController =
        TextEditingController(text: checkoutState.pointsUsedInput);
    _manualNameController.addListener(_onManualNameChanged);
  }

  @override
  void dispose() {
    _manualNameController.removeListener(_onManualNameChanged);
    _manualNameController.dispose();
    _manualQtyController.dispose();
    _manualPriceController.dispose();
    _cashController.dispose();
    _nonCashController.dispose();
    _memberIdController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(manualTransactionControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final shouldShowManualFields = _manualNameController.text.trim().isNotEmpty;
    _syncPaymentControllers(
      checkoutState: checkoutState,
      total: transactionState.subtotal,
    );
    _syncMemberControllers(checkoutState: checkoutState);
    final preview = ref
        .read(checkoutControllerProvider.notifier)
        .buildPreview(transactionState.subtotal);
    final showPaymentMethodSection = preview.requiresAdditionalPayment;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            DemoScreenHeader(
              title: 'Transaksi Manual',
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
                  onTap: () => context.go(AppRoutes.transactions),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _openProductPicker,
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Ambil dari Produk'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Item Manual',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ketik nama item dulu. Qty dan harga akan muncul setelah nama terisi.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _manualNameController,
                          label: 'Nama Item',
                          hintText: 'Contoh: Jasa Antar, Packaging, dll',
                          prefixIcon: Icons.edit_note_rounded,
                        ),
                        if (shouldShowManualFields) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _manualQtyController,
                                  label: 'Qty',
                                  hintText: '1',
                                  prefixIcon: Icons.format_list_numbered_rounded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: _manualPriceController,
                                  label: 'Harga',
                                  hintText: 'Masukkan harga item',
                                  prefixIcon: Icons.payments_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    const RupiahInputFormatter(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _addManualItem,
                              child: const Text('Tambahkan Item'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Item Transaksi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (transactionState.isEmpty)
                    const _EmptyManualItemState()
                  else
                    SurfaceCard(
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < transactionState.items.length;
                              index++) ...[
                            _ManualTransactionItemTile(
                              item: transactionState.items[index],
                              onIncrement: () => _incrementItem(
                                transactionState.items[index].id!,
                              ),
                              onDecrement: () => ref
                                  .read(
                                    manualTransactionControllerProvider.notifier,
                                  )
                                  .decrementItem(
                                    transactionState.items[index].id!,
                                  ),
                              onRemove: () => ref
                                  .read(
                                    manualTransactionControllerProvider.notifier,
                                  )
                                  .removeItem(
                                    transactionState.items[index].id!,
                                  ),
                            ),
                            if (index < transactionState.items.length - 1)
                              const Divider(
                                height: 18,
                                color: AppColors.border,
                              ),
                          ],
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const Spacer(),
                              Text(
                                RupiahFormatter.format(
                                  transactionState.subtotal,
                                ),
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
                    subtotal: transactionState.subtotal,
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
                      onChanged: (method) => ref
                          .read(checkoutControllerProvider.notifier)
                          .setPaymentMethod(
                            method,
                            subtotal: transactionState.subtotal,
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
                            total: transactionState.subtotal,
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
                    onPressed: _submitTransaction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onManualNameChanged() => setState(() {});

  void _syncPaymentControllers({
    required CheckoutState checkoutState,
    required double total,
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
    final payableTotal = checkoutNotifier.payableTotal(total);
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
    required double total,
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
                    subtotal: total,
                  ),
          onSubmitted: (value) =>
              ref.read(checkoutControllerProvider.notifier).setCashAmountInput(
                    value,
                    subtotal: total,
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

  Future<void> _openProductPicker() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ProductPickerSheet(),
    );

    if (product == null || !mounted) {
      return;
    }

    final added = ref
        .read(manualTransactionControllerProvider.notifier)
        .addCatalogProduct(product);

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qty sudah mencapai stok yang tersedia.'),
        ),
      );
    }
  }

  void _addManualItem() {
    final name = _manualNameController.text.trim();
    final qty = int.tryParse(_manualQtyController.text.trim()) ?? 0;
    final price = RupiahFormatter.parse(_manualPriceController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama item wajib diisi ya.')),
      );
      return;
    }

    if (qty < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qty minimal 1 ya.')),
      );
      return;
    }

    ref.read(manualTransactionControllerProvider.notifier).addManualItem(
          name: name,
          quantity: qty,
          unitPrice: price,
        );

    _manualNameController.clear();
    _manualQtyController.text = '1';
    _manualPriceController.clear();
    setState(() {});
  }

  void _incrementItem(String itemId) {
    final success = ref
        .read(manualTransactionControllerProvider.notifier)
        .incrementItem(itemId);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qty sudah mencapai stok yang tersedia.'),
        ),
      );
    }
  }

  Future<void> _submitTransaction() async {
    final transactionState = ref.read(manualTransactionControllerProvider);
    ref.read(checkoutControllerProvider.notifier).setCashAmountInput(
          _cashController.text,
          subtotal: transactionState.subtotal,
        );
    ref
        .read(checkoutControllerProvider.notifier)
        .setNonCashAmountInput(_nonCashController.text);

    final result = await ref.read(checkoutControllerProvider.notifier).submitCheckout(
          items: transactionState.items,
          subtotal: transactionState.subtotal,
        );

    if (result == null || !mounted) {
      return;
    }

    ref.read(manualTransactionControllerProvider.notifier).clear();
    ref.read(checkoutControllerProvider.notifier).reset();
    _cashController.clear();
    _nonCashController.clear();
    _memberIdController.clear();
    _pointsController.clear();
    ref.invalidate(transactionListControllerProvider);

    context.pushReplacement(
      AppRoutes.transactionInvoice(result.id),
    );
  }
}

class _EmptyManualItemState extends StatelessWidget {
  const _EmptyManualItemState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada item transaksi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan item dari produk atau buat item manual untuk mulai transaksi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ManualTransactionItemTile extends StatelessWidget {
  const _ManualTransactionItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final TransactionInputItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (item.isManual)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Manual',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${RupiahFormatter.format(item.unitPrice)} x ${item.quantity}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                RupiahFormatter.format(item.lineSubtotal),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyActionButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                _QtyActionButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyActionButton extends StatelessWidget {
  const _QtyActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _loadProducts([String? search]) {
    return ref.read(getProductsUseCaseProvider).call(search: search);
  }

  void _refreshSearch() {
    setState(() {
      final search = _searchController.text.trim();
      _futureProducts = _loadProducts(search.isEmpty ? null : search);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ambil dari Produk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih produk dari daftar. Yang ditampilkan hanya nama, stok, dan harga.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _searchController,
                      label: 'Cari Produk',
                      hintText: 'Ketik nama produk',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (_) => _refreshSearch(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data ?? const <Product>[];
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          'Produk tidak ditemukan.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: product.stock <= 0
                                ? null
                                : () => Navigator.of(context).pop(product),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stok: ${product.stock}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    RupiahFormatter.format(product.sellingPrice),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: product.stock <= 0
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: products.length,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
