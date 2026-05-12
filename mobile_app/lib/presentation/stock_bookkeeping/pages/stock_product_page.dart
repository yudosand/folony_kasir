import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../controllers/stock_card_controller.dart';

class StockProductPage extends ConsumerWidget {
  const StockProductPage({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockCardControllerProvider(productId));
    final notifier = ref.read(stockCardControllerProvider(productId).notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            state.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error is ApiException
                        ? error.message
                        : 'Kartu stok belum berhasil dimuat. Coba lagi ya.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (card) => RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  card.product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              _StatusBox(
                                label: card.product.stockStatusLabel,
                                status: card.product.stockStatus,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Harga jual ${RupiahFormatter.format(card.product.sellingPrice)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _SummaryBadge(
                                label: 'Stok kini',
                                value: '${card.product.stock}',
                              ),
                              _SummaryBadge(
                                label: 'Min stok',
                                value: '${card.product.minimumStock}',
                              ),
                              _SummaryBadge(
                                label: 'Stok awal',
                                value: '${card.initialStock}',
                              ),
                              _SummaryBadge(
                                label: 'Masuk',
                                value: '${card.stockIn}',
                              ),
                              _SummaryBadge(
                                label: 'Keluar',
                                value: '${card.stockOut}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _openRestockDialog(
                                    context,
                                    notifier,
                                  ),
                                  child: const Text('Restock'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _openAdjustmentDialog(
                                    context,
                                    notifier,
                                  ),
                                  child: const Text('Penyesuaian'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Riwayat Mutasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (card.movements.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Belum ada mutasi stok pada produk ini.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...card.movements.map(
                        (movement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _movementLabel(movement.type),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${movement.direction == 'in' ? '+' : '-'}${movement.quantity}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: movement.direction == 'in'
                                                ? const Color(0xFF166534)
                                                : AppColors.danger,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Stok ${movement.stockBefore} -> ${movement.stockAfter}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                if ((movement.notes ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    movement.notes!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(movement.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
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
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 64,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0x12000000),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kartu Stok',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRestockDialog(
    BuildContext context,
    StockCardController notifier,
  ) async {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final costController = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restock Produk'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Qty Restock',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga beli opsional',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldSubmit || !context.mounted) {
      return;
    }

    try {
      await notifier.restock(
        quantity: int.parse(quantityController.text.trim()),
        unitCost: costController.text.trim().isEmpty
            ? null
            : double.tryParse(costController.text.trim()),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Restock berhasil dicatat.');
    } on ApiException catch (exception) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, exception.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Restock belum berhasil disimpan.');
    }
  }

  Future<void> _openAdjustmentDialog(
    BuildContext context,
    StockCardController notifier,
  ) async {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    var direction = 'out';

    final shouldSubmit = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Penyesuaian Stok'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: direction,
                    items: const [
                      DropdownMenuItem(
                        value: 'out',
                        child: Text('Kurangi stok'),
                      ),
                      DropdownMenuItem(
                        value: 'in',
                        child: Text('Tambah stok'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          direction = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Arah penyesuaian',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!shouldSubmit || !context.mounted) {
      return;
    }

    try {
      await notifier.adjust(
        direction: direction,
        quantity: int.parse(quantityController.text.trim()),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Penyesuaian stok berhasil dicatat.');
    } on ApiException catch (exception) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, exception.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Penyesuaian stok belum berhasil disimpan.');
    }
  }

  String _movementLabel(String type) {
    switch (type) {
      case 'opening':
        return 'Stok Awal';
      case 'sale':
        return 'Penjualan';
      case 'restock':
        return 'Restock';
      case 'adjustment':
        return 'Penyesuaian';
      default:
        return type;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.label,
    required this.status,
  });

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'out':
        color = AppColors.danger;
        break;
      case 'low':
        color = const Color(0xFFB45309);
        break;
      default:
        color = const Color(0xFF166534);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
