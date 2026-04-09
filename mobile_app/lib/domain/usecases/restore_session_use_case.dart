import '../../core/errors/api_exception.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> call() async {
    final token = await _repository.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await _repository.getMe();
      return AuthSession(
        token: token,
        tokenType: 'Bearer',
        user: user,
      );
    } on ApiException catch (exception) {
      if (exception.statusCode == 401) {
        await _repository.clearSession();
        return null;
      }

      rethrow;
    }
  }
}
