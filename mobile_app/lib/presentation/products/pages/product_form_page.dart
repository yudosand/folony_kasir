import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/entities/product.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../controllers/product_form_controller.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({
    super.key,
    this.product,
  });

  final Product? product;

  bool get isEditMode => product != null;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _stockController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _stockController =
        TextEditingController(text: product?.stock.toString() ?? '');
    _costPriceController = TextEditingController(
      text:
          product == null ? '' : RupiahFormatter.formatInput(product.costPrice),
    );
    _sellingPriceController = TextEditingController(
      text: product == null
          ? ''
          : RupiahFormatter.formatInput(product.sellingPrice),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final stock = int.parse(_stockController.text.trim());
    final costPrice = RupiahFormatter.parse(_costPriceController.text);
    final sellingPrice = RupiahFormatter.parse(_sellingPriceController.text);

    try {
      await ref
          .read(productFormControllerProvider(widget.product).notifier)
          .submit(
            name: _nameController.text.trim(),
            stock: stock,
            costPrice: costPrice,
            sellingPrice: sellingPrice,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Produk berhasil diperbarui.'
                : 'Produk berhasil ditambahkan.',
          ),
        ),
      );
      context.pop(true);
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
    final formState = ref.watch(productFormControllerProvider(widget.product));
    final controller =
        ref.read(productFormControllerProvider(widget.product).notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 76, 20, 32),
              child: Form(
                key: _formKey,
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImageSection(
                        formState: formState,
                        onTap: formState.isSubmitting
                            ? null
                            : () => _showImageOptions(controller, formState),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameController,
                        label: 'Nama Produk',
                        hintText: 'Masukkan Nama Produk',
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama produk wajib diisi ya.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _stockController,
                        label: 'Jumlah Stok',
                        hintText: 'Masukkan Jumlah Stok',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        selectAllOnTap: widget.isEditMode,
                        validator: _validateStock,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _costPriceController,
                        label: 'Harga Beli',
                        hintText: 'Masukkan Harga Beli',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          const RupiahInputFormatter(),
                        ],
                        selectAllOnTap: widget.isEditMode,
                        validator: (value) => _validateAmount(
                          value,
                          fieldLabel: 'Harga modal',
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _sellingPriceController,
                        label: 'Harga Jual',
                        hintText: 'Masukkan Harga Jual',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          const RupiahInputFormatter(),
                        ],
                        selectAllOnTap: widget.isEditMode,
                        validator: (value) => _validateAmount(
                          value,
                          fieldLabel: 'Harga jual',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (formState.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            formState.errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      PrimaryButton(
                        label: widget.isEditMode
                            ? 'Simpan Perubahan'
                            : 'Tambah Produk',
                        isLoading: formState.isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DemoScreenHeader(
                title: widget.isEditMode ? 'Ubah Produk' : 'Tambah Produk',
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

  Future<void> _showImageOptions(
    ProductFormController controller,
    ProductFormState formState,
  ) async {
    final canRemove = formState.selectedImagePath != null ||
        formState.hasExistingImage ||
        formState.removeExistingImage;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kelola Foto Produk',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih foto dari galeri, ambil dari kamera, atau hapus foto saat ini.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Buka Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                if (canRemove)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.removeImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stok wajib diisi ya.';
    }

    final stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'Stok harus berupa angka bulat ya.';
    }

    if (stock < 0) {
      return 'Stok tidak boleh kurang dari 0 ya.';
    }

    return null;
  }

  String? _validateAmount(
    String? value, {
    required String fieldLabel,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel wajib diisi ya.';
    }

    final amount = RupiahFormatter.parse(value);
    if (amount < 0) {
      return '$fieldLabel tidak boleh kurang dari 0 ya.';
    }

    return null;
  }
}

class _ProductImagePreview extends StatelessWidget {
  const _ProductImagePreview({
    required this.formState,
  });

  final ProductFormState formState;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (formState.selectedImagePath != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(formState.selectedImagePath!),
          fit: BoxFit.cover,
        ),
      );
    } else if (formState.hasExistingImage) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          formState.initialProduct!.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const _ImagePlaceholder();
          },
        ),
      );
    } else if (formState.removeExistingImage) {
      child = const _RemovedImageNotice();
    } else {
      child = const _ImagePlaceholder();
    }

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _ProductImageSection extends StatelessWidget {
  const _ProductImageSection({
    required this.formState,
    required this.onTap,
  });

  final ProductFormState formState;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _ProductImagePreview(formState: formState),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap foto untuk pilih dari galeri, kamera, atau hapus',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 42,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada gambar',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _RemovedImageNotice extends StatelessWidget {
  const _RemovedImageNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF3F3),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_outline,
            size: 42,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          Text(
            'Gambar akan dihapus saat produk disimpan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
          ),
        ],
      ),
    );
  }
}
