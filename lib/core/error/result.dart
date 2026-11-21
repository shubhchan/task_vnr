import 'package:equatable/equatable.dart';

/// What went wrong, in a shape the UI can show without knowing about Dio or Hive.
sealed class AppFailure extends Equatable {
  const AppFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'The request timed out']);
}

final class ParsingFailure extends AppFailure {
  const ParsingFailure([super.message = 'Could not read the data']);
}

final class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Local storage error']);
}

final class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Login failed']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

/// Small result wrapper so every layer returns success or failure instead of
/// throwing. Use [fold] in notifiers to turn it into UI state.
sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final failure) => failure,
  };

  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
