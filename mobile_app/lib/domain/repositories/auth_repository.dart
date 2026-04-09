import '../entities/app_user.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  });

  Future<AuthSession> login({
    required String phone,
    required String password,
  });

  Future<AppUser> getMe();

  Future<void> logout();

  Future<void> clearSession();

  Future<String?> readToken();
}
