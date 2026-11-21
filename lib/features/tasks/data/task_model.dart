import '../domain/task.dart';

/// DTO for the JSONPlaceholder `/todos` response.
///
/// The API only gives `id`, `title`, and `completed`.
/// Amount, category, and due date are seeded here so the list looks real.
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: (json['title'] as String? ?? '').trim(),
      completed: json['completed'] as bool? ?? false,
    );
  }

  final int id;
  final String title;
  final bool completed;

  Task toDomain({DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    return Task(
      id: 'seed-$id',
      title: title.isEmpty ? 'Untitled task' : title,
      amount: _seedAmount(id),
      category: _seedCategory(id),
      dueDate: createdAt.add(Duration(days: (id % 7) + 1)),
      createdAt: createdAt,
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      isSynced: true,
    );
  }

  static double _seedAmount(int id) => ((id % 9) + 1) * 250.0;

  static TaskCategory _seedCategory(int id) =>
      TaskCategory.values[id % TaskCategory.values.length];
}
