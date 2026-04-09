import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/store_setting.dart';

final storeSettingControllerProvider =
    AutoDisposeNotifierProvider<StoreSettingController, StoreSettingState>(
  StoreSettingController.new,
);

class StoreSettingController extends AutoDisposeNotifier<StoreSettingState> {
  @override
  StoreSettingState build() => const StoreSettingState(isLoading: true);

  Future<void> loadInitial() async {
    if (!state.isLoading) {
      return;
    }

    await _fetchStoreSetting();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    await _fetchStoreSetting();
  }

  Future<StoreSetting?> save({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    bool removeLogo = false,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final storeSetting = await ref.read(updateStoreSettingUseCaseProvider)(
        storeName: storeName,
        storeAddress: storeAddress,
        phoneNumber: phoneNumber,
        invoiceFooter: invoiceFooter,
        logoFilePath: logoFilePath,
        removeLogo: removeLogo,
      );

      state = state.copyWith(
        storeSetting: storeSetting,
        isSaving: false,
        successMessage: 'Pengaturan toko berhasil disimpan.',
      );

      return storeSetting;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void clearFeedback() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  Future<void> _fetchStoreSetting() async {
    try {
      final storeSetting = await ref.read(getStoreSettingUseCaseProvider)();
      state = state.copyWith(
        storeSetting: storeSetting,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}

class StoreSettingState {
  const StoreSettingState({
    required this.isLoading,
    this.storeSetting,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final StoreSetting? storeSetting;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  StoreSettingState copyWith({
    bool? isLoading,
    StoreSetting? storeSetting,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return StoreSettingState(
      isLoading: isLoading ?? this.isLoading,
      storeSetting: storeSetting ?? this.storeSetting,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}
