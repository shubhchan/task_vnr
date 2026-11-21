import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/profile_menu.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_notifier.dart';
import 'widgets/spending_chart.dart';
import 'widgets/summary_card.dart';

/// Financial summary and category chart derived from the task list.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskNotifier>().state;
    final byCategory = <TaskCategory, double>{};
    for (final task in state.tasks) {
      byCategory[task.category] =
          (byCategory[task.category] ?? 0) + task.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ProfileMenu(
                email: context.select<AuthNotifier, String?>(
                  (notifier) => notifier.state.email,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SummaryCard(
            budget: AppConstants.defaultBudget,
            spent: state.totalSpent,
          ),
          SpendingChart(byCategory: byCategory),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: Text('${state.unsyncedCount} task(s) waiting to sync'),
                subtitle: Text(
                  '${state.pendingCount} pending · '
                  '${state.isSyncing ? 'Syncing…' : 'Auto-sync on reconnect'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
