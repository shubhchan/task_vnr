import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../tasks/domain/task.dart';
import 'spending_colors.dart';

/// Full-screen details for one tapped chart category.
/// The expanded header uses the category colour as its background.
class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
  });

  final TaskCategory category;
  final double amount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = SpendingColors.of(category);
    final onColor = SpendingColors.on(category);
    final percent = total == 0 ? 0 : (amount / total * 100).round();
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            foregroundColor: onColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _capitalize(category.name),
                style: TextStyle(color: onColor),
              ),
              background: Hero(
                tag: 'spending-${category.name}',
                child: Container(
                  color: color,
                  alignment: Alignment.center,
                  child: Icon(
                    _iconFor(category),
                    size: 84,
                    color: onColor.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total spent',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        money.format(amount),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$percent% of total spending',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _descriptionFor(category),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(TaskCategory category) => switch (category) {
    TaskCategory.work => Icons.work_outline,
    TaskCategory.personal => Icons.eco_outlined,
    TaskCategory.travel => Icons.local_shipping_outlined,
    TaskCategory.food => Icons.restaurant_outlined,
  };

  String _descriptionFor(TaskCategory category) => switch (category) {
    TaskCategory.work => 'Office work and internal tasks for the seeds team.',
    TaskCategory.personal => 'Personal purchases made by the manager.',
    TaskCategory.travel => 'Field visits, warehouse trips, and audits.',
    TaskCategory.food => 'Team meals and refreshments.',
  };
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
