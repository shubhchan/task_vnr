import '../../../core/constants/app_constants.dart';
import '../../../core/error/result.dart';
import '../domain/auth_repository.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<String?> readToken() => _local.readToken();

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    // Simulate the network round trip from the brief.
    await Future<void>.delayed(AppConstants.mockLoginDelay);

    if (email.trim().isEmpty || password.isEmpty) {
      return const Failure<void>(
        AuthFailure('Email and password are required'),
      );
    }

    try {
      final token = 'mock-${DateTime.now().millisecondsSinceEpoch}';
      await _local.saveToken(token);
      return const Success<void>(null);
    } catch (_) {
      return const Failure<void>(StorageFailure());
    }
  }

  @override
  Future<void> logout() => _local.clearToken();
}
