import '../../../core/error/result.dart';

abstract interface class AuthRepository {
  /// Returns the stored token, or null when the user is signed out.
  Future<String?> readToken();

  /// Fakes an API call, then stores a token on success.
  Future<Result<void>> login({required String email, required String password});

  Future<void> logout();
}
