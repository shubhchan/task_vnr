import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity_plus so the rest of the app deals with a plain bool.
class SyncService {
  SyncService(this._connectivity);

  final Connectivity _connectivity;

  /// Emits `true` when any network interface is available.
  Stream<bool> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
