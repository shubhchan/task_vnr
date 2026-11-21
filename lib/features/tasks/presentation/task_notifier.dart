import 'package:flutter/foundation.dart';

import '../domain/task.dart';
import '../domain/task_repository.dart';
import 'task_state.dart';

/// Owns the task list, filters, and sync flags.
/// Screens only read [state] and call these methods.
class TaskNotifier extends ChangeNotifier {
  TaskNotifier(this._repository);

  final TaskRepository _repository;

  TaskState _state = const TaskState();
  TaskState get state => _state;

  Future<void> load() async {
    _set(_state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.loadTasks();
    result.fold(
      (failure) =>
          _set(_state.copyWith(isLoading: false, error: failure.message)),
      (tasks) => _set(
        _state.copyWith(isLoading: false, tasks: tasks, clearError: true),
      ),
    );
  }

  void setFilter(TaskFilter filter) {
    _set(_state.copyWith(filter: filter));
  }

  void search(String query) {
    _set(_state.copyWith(query: query));
  }

  Future<void> save(Task task) async {
    final result = await _repository.saveTask(task);
    result.fold((failure) => _set(_state.copyWith(error: failure.message)), (
      saved,
    ) {
      final rest = _state.tasks.where((item) => item.id != saved.id);
      final tasks = [...rest, saved]
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _set(_state.copyWith(tasks: tasks, clearError: true));
    });
  }

  /// Toggles completion and returns the updated task, or null on failure.
  Future<Task?> toggle(Task task) async {
    final next = task.isCompleted ? task.markPending() : task.markCompleted();
    return _persist(next);
  }

  Future<void> delete(Task task) async {
    final result = await _repository.deleteTask(task.id);
    result.fold(
      (failure) => _set(_state.copyWith(error: failure.message)),
      (_) => _set(
        _state.copyWith(
          tasks: _state.tasks
              .where((item) => item.id != task.id)
              .toList(growable: false),
          clearError: true,
        ),
      ),
    );
  }

  /// Puts back a deleted task. Used by the Undo snackbar action.
  Future<Task?> restore(Task task) => _persist(task);

  Future<void> syncPending() async {
    if (_state.isSyncing) {
      return;
    }
    _set(_state.copyWith(isSyncing: true, clearError: true));
    final result = await _repository.syncPending();
    result.fold(
      (failure) =>
          _set(_state.copyWith(isSyncing: false, error: failure.message)),
      (count) {
        final synced = _state.tasks
            .map((task) => task.isSynced ? task : task.copyWith(isSynced: true))
            .toList(growable: false);
        _set(
          _state.copyWith(
            isSyncing: false,
            tasks: synced,
            lastSyncedCount: count,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<Task?> _persist(Task task) async {
    final result = await _repository.saveTask(task);
    return result.fold(
      (failure) {
        _set(_state.copyWith(error: failure.message));
        return null;
      },
      (saved) {
        final tasks = _state.tasks
            .map((item) => item.id == saved.id ? saved : item)
            .toList(growable: false);
        _set(_state.copyWith(tasks: tasks, clearError: true));
        return saved;
      },
    );
  }

  void _set(TaskState next) {
    _state = next;
    notifyListeners();
  }
}
