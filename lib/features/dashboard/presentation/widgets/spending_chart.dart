import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../tasks/domain/task.dart';

/// Pie chart of spend per category, built with fl_chart.
class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key, required this.byCategory});

  final Map<TaskCategory, double> byCategory;

  static const _colors = {
    TaskCategory.work: Color(0xFF4F6BED),
    TaskCategory.personal: Color(0xFF26A69A),
    TaskCategory.travel: Color(0xFFF59E0B),
    TaskCategory.food: Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final entries = byCategory.entries.where((item) => item.value > 0).toList();
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
            else
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 44,
                    sections: [
                      for (final entry in entries)
                        PieChartSectionData(
                          value: entry.value,
                          color: _colors[entry.key],
                          title: '',
                          radius: 36,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
            if (entries.isNotEmpty) const SizedBox(height: 12),
            if (entries.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (final entry in entries)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _colors[entry.key],
                            borderRadius: BorderRadius.circular(3),
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
        ),
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
