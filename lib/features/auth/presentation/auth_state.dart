import 'package:equatable/equatable.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.checking,
    this.isLoading = false,
    this.error,
    this.email,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? error;
  final String? email;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, error, email];
}
