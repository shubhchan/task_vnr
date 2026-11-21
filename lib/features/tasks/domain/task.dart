import 'package:equatable/equatable.dart';

/// The buckets a task can fall into.
/// If I add a new one here, update the chips in the task form too.
enum TaskCategory { work, personal, travel, food }

enum TaskStatus { pending, completed }

/// A single task with its expense.
///
/// Plain immutable class with no code generation.
/// [copyWith] and [props] are written by hand to keep it easy to follow.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.createdAt,
    this.category = TaskCategory.personal,
    this.status = TaskStatus.pending,
    this.isSynced = false,
    this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final DateTime createdAt;
  final TaskCategory category;
  final TaskStatus status;

  // Anything created or edited offline sits here until the queue syncs it.
  final bool isSynced;
  final DateTime? updatedAt;

  bool get isPending => status == TaskStatus.pending;

  bool get isCompleted => status == TaskStatus.completed;

  // Zero-amount tasks are still valid, so don't use this to hide rows.
  bool get hasExpense => amount > 0;

  Task copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    DateTime? createdAt,
    TaskCategory? category,
    TaskStatus? status,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Snapshot of a completed task. Keeps the amount so reports don't lose it.
  Task markCompleted() => copyWith(
    status: TaskStatus.completed,
    updatedAt: DateTime.now(),
    isSynced: false,
  );

  Task markPending() => copyWith(
    status: TaskStatus.pending,
    updatedAt: DateTime.now(),
    isSynced: false,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    dueDate,
    createdAt,
    category,
    status,
    isSynced,
    updatedAt,
  ];
}
