import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../tasks/presentation/task_notifier.dart';
import '../data/sync_service.dart';

/// Watches the network and kicks off a sync when the device comes back online.
class ConnectivityNotifier extends ChangeNotifier {
  ConnectivityNotifier({
    required SyncService syncService,
    required TaskNotifier taskNotifier,
  }) : _syncService = syncService,
       _taskNotifier = taskNotifier;

  final SyncService _syncService;
  final TaskNotifier _taskNotifier;

  StreamSubscription<bool>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> start() async {
    _isOnline = await _syncService.isOnline();
    _subscription = _syncService.onStatusChanged.listen(_handleChange);
    notifyListeners();
  }

  void _handleChange(bool online) {
    if (online == _isOnline) {
      return;
    }
    _isOnline = online;
    notifyListeners();

    if (online) {
      // Fire and forget: the notifier guards against overlapping runs.
      unawaited(_taskNotifier.syncPending());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
