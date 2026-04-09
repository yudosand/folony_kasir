import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/indonesian_date_formatter.dart';
import '../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/transaction_summary.dart';
import '../auth/controllers/session_controller.dart';
import '../cart/controllers/cart_controller.dart';
import '../products/controllers/product_list_controller.dart';
import '../transactions/controllers/transaction_list_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final productsState = ref.watch(productListControllerProvider);
    final transactionsState = ref.watch(transactionListControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final user = session?.user;
    final displayName = user?.name ?? 'Kasir';
    final todayLabel = IndonesianDateFormatter.fullDate(DateTime.now());
    final todayStats = _buildTodayStats(transactionsState.valueOrNull);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref
                      .read(productListControllerProvider.notifier)
                      .refreshProducts(),
                  ref
                      .read(transactionListControllerProvider.notifier)
                      .refreshTransactions(),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 122),
                children: [
                  Text(
                    'Halo, $displayName',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    todayLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'Hari Ini',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x24FF7C45),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _OverviewStat(
                                title: 'Omzet Hari Ini',
                                value: RupiahFormatter.format(
                                    todayStats.totalSales),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewStat(
                                title: 'Total Transaksi',
                                value:
                                    '${todayStats.transactionCount} Transaksi',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton(
                            onPressed: () => context.go(AppRoutes.transactions),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF245C43),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Lihat Laporan Transaksi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Daftar Produk',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => context.go(AppRoutes.products),
                          readOnly: true,
                          onTap: () => context.go(AppRoutes.products),
                          decoration: const InputDecoration(
                            hintText: 'Cari produk',
                            prefixIcon: Icon(Icons.search),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  productsState.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    error: (_, __) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Daftar produk belum berhasil dimuat. Coba lagi ya.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Belum ada produk. Tambahkan produk dari menu Produk.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }

                      final previewProducts = products.take(6).toList();
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: previewProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.54,
                        ),
                        itemBuilder: (context, index) {
                          final product = previewProducts[index];
                          return _HomeProductTile(
                            product: product,
                            onAdd: () => _handleAddToCart(product),
                            onDecrement: () {
                              final cartNotifier =
                                  ref.read(cartControllerProvider.notifier);
                              final currentQuantity = ref
                                  .read(cartControllerProvider)
                                  .items
                                  .where((item) => item.productId == product.id)
                                  .map((item) => item.quantity)
                                  .firstOrNull;

                              if (currentQuantity == null) {
                                return;
                              }

                              if (currentQuantity <= 1) {
                                cartNotifier.removeItem(product.id);
                              } else {
                                cartNotifier.decrementItem(product.id);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: InkWell(
                onTap: () => context.push(AppRoutes.cart),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22FF7C45),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Produk Yang Dipilih',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${cartState.totalItems} Produk',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _TodayStats _buildTodayStats(List<TransactionSummary>? transactions) {
    if (transactions == null) {
      return const _TodayStats(transactionCount: 0, totalSales: 0);
    }

    final now = DateTime.now();
    final todayTransactions = transactions.where((transaction) {
      final createdAt = transaction.createdAt?.toLocal();
      if (createdAt == null) {
        return false;
      }

      return createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;
    }).toList();

    final totalSales = todayTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.grandTotal,
    );

    return _TodayStats(
      transactionCount: todayTransactions.length,
      totalSales: totalSales,
    );
  }

  void _handleAddToCart(Product product) {
    final beforeCount = ref.read(cartControllerProvider).totalItems;
    ref.read(cartControllerProvider.notifier).addProduct(product);
    final afterCount = ref.read(cartControllerProvider).totalItems;

    if (afterCount == beforeCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qty sudah mencapai stok yang tersedia.'),
        ),
      );
    }
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _HomeProductTile extends ConsumerWidget {
  const _HomeProductTile({
    required this.product,
    required this.onAdd,
    required this.onDecrement,
  });

  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(
      cartControllerProvider.select((state) {
        for (final item in state.items) {
          if (item.productId == product.id) {
            return item.quantity;
          }
        }

        return 0;
      }),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 72,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primaryDark,
                            size: 30,
                          ),
                        )
                      : Container(
                          color: AppColors.primarySoft,
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: AppColors.primarySoft,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.primaryDark,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      RupiahFormatter.format(product.sellingPrice),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Stok: ${product.stock}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    if (quantity <= 0)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: onDecrement,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '$quantity',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: onAdd,
                                ),
                              ],
                            ),
                          ),
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
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
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
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}

class _TodayStats {
  const _TodayStats({
    required this.transactionCount,
    required this.totalSales,
  });

  final int transactionCount;
  final double totalSales;
}
