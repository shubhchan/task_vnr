import '../../../core/error/result.dart';
import 'task.dart';

/// What the presentation layer is allowed to ask for.
/// Implementations live in the data layer and hide Hive and Dio.
abstract interface class TaskRepository {
  /// Reads local tasks. Seeds from the mock API on first launch.
  Future<Result<List<Task>>> loadTasks();

  /// Inserts or updates a task and marks it unsynced.
  Future<Result<Task>> saveTask(Task task);

  Future<Result<void>> deleteTask(String id);

  /// Flips every pending task to synced. Returns how many were synced.
  Future<Result<int>> syncPending();
}
