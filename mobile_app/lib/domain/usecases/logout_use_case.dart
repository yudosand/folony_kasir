import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({bool notifyServer = true}) async {
    if (notifyServer) {
      await _repository.logout();
      return;
    }

    await _repository.clearSession();
  }
}
