import '../../domain/entities/store_setting.dart';
import '../../domain/repositories/store_setting_repository.dart';
import '../datasources/remote/store_setting_remote_data_source.dart';

class StoreSettingRepositoryImpl implements StoreSettingRepository {
  const StoreSettingRepositoryImpl(this._remoteDataSource);

  final StoreSettingRemoteDataSource _remoteDataSource;

  @override
  Future<StoreSetting?> getStoreSetting() async {
    final storeSetting = await _remoteDataSource.getStoreSetting();
    return storeSetting?.toEntity();
  }

  @override
  Future<StoreSetting> updateStoreSetting({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    bool removeLogo = false,
  }) async {
    final storeSetting = await _remoteDataSource.updateStoreSetting(
      storeName: storeName,
      storeAddress: storeAddress,
      phoneNumber: phoneNumber,
      invoiceFooter: invoiceFooter,
      logoFilePath: logoFilePath,
      removeLogo: removeLogo,
    );

    return storeSetting.toEntity();
  }
}
