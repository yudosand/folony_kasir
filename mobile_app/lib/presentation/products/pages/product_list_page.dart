import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/delete_product_dialog.dart';
import '../widgets/product_card.dart';
import '../../../domain/entities/product.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateForm() async {
    final didChange = await context.push<bool>(AppRoutes.productCreate);
    if (!mounted || didChange != true) {
      return;
    }

    await ref.read(productListControllerProvider.notifier).refreshProducts();
  }

  Future<void> _openEditForm(Product product) async {
    final didChange = await context.push<bool>(
      AppRoutes.productEdit(product.id),
      extra: product,
    );
    if (!mounted || didChange != true) {
      return;
    }

    await ref.read(productListControllerProvider.notifier).refreshProducts();
  }

  Future<void> _confirmDelete(Product product) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => DeleteProductDialog(productName: product.name),
        ) ??
        false;

    if (!shouldDelete || !mounted) {
      return;
    }

    try {
      await ref
          .read(productListControllerProvider.notifier)
          .deleteProduct(product.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} berhasil dihapus.')),
      );
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(exception.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productListControllerProvider);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref
                  .read(productListControllerProvider.notifier)
                  .refreshProducts(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 112),
                children: [
                  SurfaceCard(
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Daftar Produk',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: ref
                                    .read(
                                        productListControllerProvider.notifier)
                                    .updateSearchQuery,
                                decoration: const InputDecoration(
                                  hintText: 'Cari produk',
                                  prefixIcon: Icon(Icons.search),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        productsState.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: LoadingIndicator()),
                          ),
                          error: (error, _) => _ProductErrorState(
                            message: error is ApiException
                                ? error.message
                                : 'Produk belum berhasil dimuat. Coba lagi ya.',
                            onRetry: () => ref
                                .read(productListControllerProvider.notifier)
                                .refreshProducts(),
                          ),
                          data: (products) {
                            if (products.isEmpty) {
                              return const _ProductEmptyState();
                            }

                            return Column(
                              children: [
                                for (var index = 0;
                                    index < products.length;
                                    index++) ...[
                                  ProductCard(
                                    product: products[index],
                                    onTap: () =>
                                        _openEditForm(products[index]),
                                    onEdit: () =>
                                        _openEditForm(products[index]),
                                    onDelete: () =>
                                        _confirmDelete(products[index]),
                                  ),
                                  if (index < products.length - 1)
                                    const Divider(
                                      height: 18,
                                      color: AppColors.border,
                                    ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DemoScreenHeader(
                title: 'Produk Saya',
                height: 48,
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                trailing: _CartButton(
                  count: cartState.totalItems,
                  onTap: () => context.push(AppRoutes.cart),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _openCreateForm,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                  ),
                  child: const Text('+ Tambah Produk Baru'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF245C43),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductEmptyState extends StatelessWidget {
  const _ProductEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 44,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada produk',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan menambahkan produk pertama agar checkout bisa dipakai.',
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

class _ProductErrorState extends StatelessWidget {
  const _ProductErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 42,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => onRetry(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
