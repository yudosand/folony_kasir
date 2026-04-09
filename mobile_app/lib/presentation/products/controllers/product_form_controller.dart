import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../core/services/product_image_optimization_service.dart';
import '../../../domain/entities/product.dart';

final productFormControllerProvider = AutoDisposeNotifierProviderFamily<
    ProductFormController, ProductFormState, Product?>(
  ProductFormController.new,
);

class ProductFormController
    extends AutoDisposeFamilyNotifier<ProductFormState, Product?> {
  final ImagePicker _imagePicker = ImagePicker();

  Product? _initialProduct;

  @override
  ProductFormState build(Product? arg) {
    _initialProduct = arg;
    return ProductFormState(
      initialProduct: arg,
      removeExistingImage: false,
      isSubmitting: false,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (image == null) {
      return;
    }

    final optimizedImage = await _optimizeImage(image.path);
    state = state.copyWith(
      selectedImagePath: optimizedImage.filePath,
      selectedImageBytes: optimizedImage.bytes,
      removeExistingImage: false,
      clearErrorMessage: true,
    );
  }

  Future<ProductImageOptimizationResult> _optimizeImage(
    String sourcePath,
  ) async {
    try {
      return await ref
          .read(productImageOptimizationServiceProvider)
          .optimize(sourcePath);
    } catch (_) {
      return ProductImageOptimizationResult(
        filePath: sourcePath,
        bytes: await XFile(sourcePath).readAsBytes(),
      );
    }
  }

  void removeImage() {
    final hadSelectedImage = state.selectedImagePath != null;

    state = state.copyWith(
      selectedImagePath: null,
      selectedImageBytes: null,
      removeExistingImage:
          hadSelectedImage ? state.initialProduct?.imageUrl != null : true,
      clearErrorMessage: true,
    );
  }

  void restoreExistingImage() {
    state = state.copyWith(
      removeExistingImage: false,
      clearErrorMessage: true,
    );
  }

  Future<Product?> submit({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      final product = _initialProduct == null
          ? await ref.read(createProductUseCaseProvider).call(
                name: name,
                stock: stock,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                imageFilePath: state.selectedImagePath,
              )
          : await ref.read(updateProductUseCaseProvider).call(
                productId: _initialProduct!.id,
                name: name,
                stock: stock,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                imageFilePath: state.selectedImagePath,
                removeImage: state.removeExistingImage,
              );

      state = state.copyWith(isSubmitting: false);
      return product;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }
}

class ProductFormState {
  static const Object _sentinel = Object();

  const ProductFormState({
    required this.initialProduct,
    required this.removeExistingImage,
    required this.isSubmitting,
    this.selectedImagePath,
    this.selectedImageBytes,
    this.errorMessage,
  });

  final Product? initialProduct;
  final String? selectedImagePath;
  final Uint8List? selectedImageBytes;
  final bool removeExistingImage;
  final bool isSubmitting;
  final String? errorMessage;

  bool get hasExistingImage =>
      initialProduct?.imageUrl != null && !removeExistingImage;

  ProductFormState copyWith({
    Object? initialProduct = _sentinel,
    Object? selectedImagePath = _sentinel,
    Object? selectedImageBytes = _sentinel,
    bool? removeExistingImage,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    bool clearErrorMessage = false,
  }) {
    return ProductFormState(
      initialProduct: identical(initialProduct, _sentinel)
          ? this.initialProduct
          : initialProduct as Product?,
      selectedImagePath: identical(selectedImagePath, _sentinel)
          ? this.selectedImagePath
          : selectedImagePath as String?,
      selectedImageBytes: identical(selectedImageBytes, _sentinel)
          ? this.selectedImageBytes
          : selectedImageBytes as Uint8List?,
      removeExistingImage: removeExistingImage ?? this.removeExistingImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : identical(errorMessage, _sentinel)
              ? this.errorMessage
              : errorMessage as String?,
    );
  }
}
