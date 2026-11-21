import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Budget, spent, remaining, and a progress bar.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.budget, required this.spent});

  final double budget;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = budget - spent;
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Budget overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Amount(label: 'Budget', value: money.format(budget)),
                ),
                Expanded(
                  child: _Amount(label: 'Spent', value: money.format(spent)),
                ),
                Expanded(
                  child: _Amount(
                    label: 'Left',
                    value: money.format(remaining),
                    color: remaining < 0 ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 10),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}% of budget used',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
