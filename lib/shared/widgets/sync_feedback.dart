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
  TaskNotifier? _notifier;
  bool _wasSyncing = false;

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
    } else if (!state.isSyncing && _wasSyncing) {
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
    _notifier?.removeListener(_onChanged);
    super.dispose();
  }
}
