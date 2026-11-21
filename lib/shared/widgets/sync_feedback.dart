import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/tasks/presentation/task_notifier.dart';

/// Shows a subtle snack bar while a sync is running and replaces it with the
/// result. It listens to the notifier, so both manual and automatic syncs
/// produce the same feedback.
class SyncFeedback extends StatefulWidget {
  const SyncFeedback({super.key});

  @override
  State<SyncFeedback> createState() => _SyncFeedbackState();
}

class _SyncFeedbackState extends State<SyncFeedback> {
  static const _watchdog = Duration(minutes: 1);

  TaskNotifier? _notifier;
  bool _wasSyncing = false;
  Timer? _timeout;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.read<TaskNotifier>();
    if (identical(notifier, _notifier)) {
      return;
    }
    _notifier?.removeListener(_onChanged);
    _notifier = notifier;
    _wasSyncing = notifier.state.isSyncing;
    notifier.addListener(_onChanged);
  }

  void _onChanged() {
    final notifier = _notifier;
    if (notifier == null || !mounted) {
      return;
    }
    final state = notifier.state;

    if (state.isSyncing && !_wasSyncing) {
      _showSyncing();
      _timeout?.cancel();
      _timeout = Timer(_watchdog, _showTimeout);
    } else if (!state.isSyncing && _wasSyncing) {
      _timeout?.cancel();
      if (state.error != null) {
        _showError(state.error!);
      } else {
        _showDone(state.lastSyncedCount ?? 0);
      }
    }
    _wasSyncing = state.isSyncing;
  }

  void _showSyncing() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(minutes: 5),
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Syncing your changes…'),
            ],
          ),
        ),
      );
  }

  /// If a sync is still running after a minute, stop showing the waiting
  /// message and surface a clear error instead.
  void _showTimeout() {
    if (!mounted || !(_notifier?.state.isSyncing ?? false)) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Sync is taking too long. Please try again.'),
              ),
            ],
          ),
        ),
      );
  }

  void _showDone(int count) {
    final color = Theme.of(context).colorScheme.onInverseSurface;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(Icons.cloud_done_outlined, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              count > 0 ? '$count task(s) synced' : 'Everything is up to date',
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => context.read<TaskNotifier>().syncPending(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {
    _timeout?.cancel();
    _notifier?.removeListener(_onChanged);
    super.dispose();
  }
}
