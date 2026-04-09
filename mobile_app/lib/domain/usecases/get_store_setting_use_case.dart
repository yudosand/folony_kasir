import '../entities/store_setting.dart';
import '../repositories/store_setting_repository.dart';

class GetStoreSettingUseCase {
  const GetStoreSettingUseCase(this._repository);

  final StoreSettingRepository _repository;

  Future<StoreSetting?> call() {
    return _repository.getStoreSetting();
  }
}
