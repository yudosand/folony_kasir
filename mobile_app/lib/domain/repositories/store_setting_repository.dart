import '../entities/store_setting.dart';

abstract class StoreSettingRepository {
  Future<StoreSetting?> getStoreSetting();

  Future<StoreSetting> updateStoreSetting({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    bool removeLogo = false,
  });
}
