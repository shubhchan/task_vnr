import '../../../core/constants/app_constants.dart';
import '../../../core/error/result.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
import 'task_local_datasource.dart';
import 'task_remote_datasource.dart';

/// Offline-first repository.
///
/// Reads always come from Hive. The network is only used to seed the box the
/// first time the app runs, and to fake a sync for tasks flagged `isSynced`.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskLocalDataSource local,
    required TaskRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final TaskLocalDataSource _local;
  final TaskRemoteDataSource _remote;

  @override
  Future<Result<List<Task>>> loadTasks() async {
    try {
      if (_local.isEmpty) {
        await _seedFromApi();
      }

      final tasks = [..._local.readAll()]
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return Success(tasks);
    } catch (_) {
      return Failure(const StorageFailure());
    }
  }

  @override
  Future<Result<Task>> saveTask(Task task) async {
    try {
      // Any edit made through the app is queued for sync.
      final next = task.copyWith(isSynced: false, updatedAt: DateTime.now());
      await _local.put(next);
      return Success(next);
    } catch (_) {
      return Failure(const StorageFailure());
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await _local.delete(id);
      return const Success<void>(null);
    } catch (_) {
      return Failure(const StorageFailure());
    }
  }

  @override
  Future<Result<int>> syncPending() async {
    try {
      final pending = _local.pending;
      if (pending.isEmpty) {
        return const Success(0);
      }

      // Pretend the request takes a moment so the badge change is visible.
      await Future<void>.delayed(AppConstants.mockSyncDelay);
      await _local.putAll(pending.map((task) => task.copyWith(isSynced: true)));
      return Success(pending.length);
    } catch (_) {
      return Failure(const StorageFailure());
    }
  }

  /// Seed failures are ignored on purpose.
  /// First launch offline should still open to a usable empty list.
  Future<void> _seedFromApi() async {
    final result = await _remote.fetchTodos();
    final models = result.valueOrNull;
    if (models == null || models.isEmpty) {
      return;
    }
    await _local.putAll(models.take(12).map((model) => model.toDomain()));
  }
}
