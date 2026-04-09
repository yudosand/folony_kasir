import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String phone,
    required String password,
  }) {
    return _repository.login(phone: phone, password: password);
  }
}
