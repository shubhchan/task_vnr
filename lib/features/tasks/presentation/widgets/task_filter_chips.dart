import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../task_notifier.dart';
import '../task_state.dart';

/// Filter chips that rebuild only when the selected filter changes.
class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.select<TaskNotifier, TaskFilter>(
      (notifier) => notifier.state.filter,
    );
    final notifier = context.read<TaskNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final option in TaskFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_capitalize(option.name)),
                selected: filter == option,
                onSelected: (_) => notifier.setFilter(option),
              ),
            ),
        ],
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
