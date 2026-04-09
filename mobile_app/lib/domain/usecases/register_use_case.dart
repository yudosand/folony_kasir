import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) {
    return _repository.register(
      name: name,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      referal: referal,
    );
  }
}
