import '../domain/task.dart';
import 'seed_task_catalog.dart';

/// DTO for the JSONPlaceholder `/todos` response.
///
/// The API only gives `id`, `title`, and `completed`.
/// The API title is kept on the DTO, but [SeedTaskCatalog] supplies the
/// English wording, category, and expense used in the app.
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
    final seed = SeedTaskCatalog.forId(id);
    return Task(
      id: 'seed-$id',
      title: seed.title,
      amount: seed.amount,
      category: seed.category,
      dueDate: createdAt.add(Duration(days: (id % 7) + 1)),
      createdAt: createdAt,
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      isSynced: true,
    );
  }
}
