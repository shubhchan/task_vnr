import 'package:offline_example/features/tasks/domain/task.dart';

/// Shared sample so tests do not repeat constructor noise.
Task sampleTask({
  String id = 't1',
  String title = 'Buy office supplies',
  double amount = 1200,
  TaskCategory category = TaskCategory.work,
  TaskStatus status = TaskStatus.pending,
  bool isSynced = true,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: title,
    amount: amount,
    category: category,
    status: status,
    isSynced: isSynced,
    dueDate: dueDate ?? DateTime(2026, 1, 5),
    createdAt: DateTime(2026, 1, 1),
  );
}
