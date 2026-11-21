import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/task.dart';

/// One row in the task list.
/// Action callbacks are passed in so this widget stays declarative.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(task.amount);
    final due = DateFormat('dd MMM').format(task.dueDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            task.title,
            key: ValueKey(task.isCompleted),
            style: task.isCompleted
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(_capitalize(task.category.name)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text('Due $due', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!task.isSynced)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Pending sync',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
