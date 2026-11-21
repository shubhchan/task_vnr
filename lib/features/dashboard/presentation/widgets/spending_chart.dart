import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../tasks/domain/task.dart';
import '../category_detail_screen.dart';
import '../spending_colors.dart';

/// Pie chart of spend per category, built with fl_chart.
/// Tapping a section opens a full details screen with a Hero transition.
class SpendingChart extends StatefulWidget {
  const SpendingChart({super.key, required this.byCategory});

  final Map<TaskCategory, double> byCategory;

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  int? _touchedIndex;

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
                        _openDetails(context, entries[index], total);
                      },
                    ),
                    sections: [
                      for (var i = 0; i < entries.length; i++)
                        PieChartSectionData(
                          value: entries[i].value,
                          color: SpendingColors.of(entries[i].key),
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
                              color: SpendingColors.of(entry.key),
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

  void _openDetails(
    BuildContext context,
    MapEntry<TaskCategory, double> entry,
    double total,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryDetailScreen(
          category: entry.key,
          amount: entry.value,
          total: total,
        ),
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
