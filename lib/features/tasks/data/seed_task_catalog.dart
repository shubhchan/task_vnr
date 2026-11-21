import '../domain/task.dart';

/// One curated task used to seed a fresh installation.
class SeedTask {
  const SeedTask({
    required this.title,
    required this.category,
    required this.amount,
  });

  final String title;
  final TaskCategory category;
  final double amount;
}

/// Internal work at a seeds company, written in plain English.
///
/// The mock API supplies the row count and completion status.
/// This catalog supplies the wording, category, and expense.
class SeedTaskCatalog {
  const SeedTaskCatalog._();

  static const items = [
    SeedTask(
      title: 'Review hybrid seed stock levels',
      category: TaskCategory.work,
      amount: 0,
    ),
    SeedTask(
      title: 'Approve maize seed purchase order',
      category: TaskCategory.work,
      amount: 24500,
    ),
    SeedTask(
      title: 'Visit northwest distribution warehouse',
      category: TaskCategory.travel,
      amount: 3200,
    ),
    SeedTask(
      title: 'Verify germination test results',
      category: TaskCategory.work,
      amount: 0,
    ),
    SeedTask(
      title: 'Team lunch with field officers',
      category: TaskCategory.food,
      amount: 1800,
    ),
    SeedTask(
      title: 'Update dealer price list',
      category: TaskCategory.work,
      amount: 0,
    ),
    SeedTask(
      title: 'Order seed testing lab supplies',
      category: TaskCategory.work,
      amount: 5600,
    ),
    SeedTask(
      title: 'Buy vegetable seeds for home garden',
      category: TaskCategory.personal,
      amount: 650,
    ),
    SeedTask(
      title: 'Reimburse travel for field audit',
      category: TaskCategory.travel,
      amount: 2750,
    ),
    SeedTask(
      title: 'Order stationery for dispatch team',
      category: TaskCategory.work,
      amount: 1200,
    ),
    SeedTask(
      title: 'Meet cooperative society representatives',
      category: TaskCategory.work,
      amount: 900,
    ),
    SeedTask(
      title: 'File quarterly seed certification records',
      category: TaskCategory.work,
      amount: 0,
    ),
  ];

  /// Maps an API row id onto one catalog entry.
  static SeedTask forId(int id) => items[(id - 1) % items.length];
}
