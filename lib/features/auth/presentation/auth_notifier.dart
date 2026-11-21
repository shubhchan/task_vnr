import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';
import 'auth_state.dart';

/// Owns the session. The app reads [state] to decide which screen to show.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._repository);

  final AuthRepository _repository;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  /// Auto-login check on app launch.
  Future<void> checkSession() async {
    final token = await _repository.readToken();
    _set(
      _state.copyWith(
        status: token == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
      ),
    );
  }

  Future<bool> login({required String email, required String password}) async {
    _set(_state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.login(email: email, password: password);
    return result.fold(
      (failure) {
        _set(_state.copyWith(isLoading: false, error: failure.message));
        return false;
      },
      (_) {
        _set(
          _state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
            email: email,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _set(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _set(AuthState next) {
    _state = next;
    notifyListeners();
  }
}
