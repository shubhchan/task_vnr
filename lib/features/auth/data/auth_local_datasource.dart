import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/app_constants.dart';

/// Stores the mock auth token in the platform keystore.
class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.authTokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: AppConstants.authTokenKey);

  Future<void> clearToken() => _storage.delete(key: AppConstants.authTokenKey);
}
