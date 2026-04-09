import '../entities/store_setting.dart';
import '../repositories/store_setting_repository.dart';

class UpdateStoreSettingUseCase {
  const UpdateStoreSettingUseCase(this._repository);

  final StoreSettingRepository _repository;

  Future<StoreSetting> call({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    bool removeLogo = false,
  }) {
    return _repository.updateStoreSetting(
      storeName: storeName,
      storeAddress: storeAddress,
      phoneNumber: phoneNumber,
      invoiceFooter: invoiceFooter,
      logoFilePath: logoFilePath,
      removeLogo: removeLogo,
    );
  }
}
