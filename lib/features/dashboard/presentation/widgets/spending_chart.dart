import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../tasks/domain/task.dart';

/// Pie chart of spend per category, built with fl_chart.
/// Tapping a section opens a details dialog with a shared-element transition.
class SpendingChart extends StatefulWidget {
  const SpendingChart({super.key, required this.byCategory});

  final Map<TaskCategory, double> byCategory;

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  int? _touchedIndex;

  static const _colors = {
    TaskCategory.work: Color(0xFF4F6BED),
    TaskCategory.personal: Color(0xFF26A69A),
    TaskCategory.travel: Color(0xFFF59E0B),
    TaskCategory.food: Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final entries = widget.byCategory.entries
        .where((item) => item.value > 0)
        .toList();
    final total = entries.fold<double>(0, (sum, item) => sum + item.value);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Spending by category', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No expenses logged yet.',
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 44,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        final index =
                            response?.touchedSection?.touchedSectionIndex;
                        if (event is! FlTapUpEvent ||
                            index == null ||
                            index >= entries.length) {
                          return;
                        }
                        setState(() => _touchedIndex = index);
                        _showDetails(context, entries[index], total);
                      },
                    ),
                    sections: [
                      for (var i = 0; i < entries.length; i++)
                        PieChartSectionData(
                          value: entries[i].value,
                          color: _colors[entries[i].key],
                          title: '',
                          radius: _touchedIndex == i ? 44 : 36,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (final entry in entries)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'spending-${entry.key.name}',
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _colors[entry.key],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _capitalize(entry.key.name),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetails(
    BuildContext context,
    MapEntry<TaskCategory, double> entry,
    double total,
  ) {
    final theme = Theme.of(context);
    final percent = total == 0 ? 0 : (entry.value / total * 100).round();
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Hero(
              tag: 'spending-${entry.key.name}',
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _colors[entry.key],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(_capitalize(entry.key.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              money.format(entry.value),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text('$percent% of total spending'),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
