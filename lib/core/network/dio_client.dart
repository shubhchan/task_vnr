import 'package:dio/dio.dart';

/// One Dio instance for the app.
/// Timeouts live here so screens and repositories never set their own.
Dio createDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
