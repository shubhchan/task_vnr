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
  /// The list updates immediately; a failed write restores the old task.
  Future<Task?> toggle(Task task) async {
    final next = task.isCompleted ? task.markPending() : task.markCompleted();
    _replace(next);

    final result = await _repository.saveTask(next);
    return result.fold(
      (failure) {
        _replace(task);
        _set(_state.copyWith(error: failure.message));
        return null;
      },
      (saved) {
        _replace(saved);
        return saved;
      },
    );
  }

  Future<void> delete(Task task) async {
    // Remove the row first so a fast Undo cannot be overwritten later.
    _set(
      _state.copyWith(
        tasks: _state.tasks
            .where((item) => item.id != task.id)
            .toList(growable: false),
        clearError: true,
      ),
    );

    final result = await _repository.deleteTask(task.id);
    if (result.isFailure) {
      final message = result.failureOrNull?.message;
      if (!_state.tasks.any((item) => item.id == task.id)) {
        final tasks = [..._state.tasks, task]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        _set(_state.copyWith(tasks: tasks, error: message));
      } else {
        _set(_state.copyWith(error: message));
      }
    }
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
    final wasDeleted = !_state.tasks.any((item) => item.id == task.id);
    final result = await _repository.saveTask(task);
    return result.fold(
      (failure) {
        _set(_state.copyWith(error: failure.message));
        return null;
      },
      (saved) {
        if (wasDeleted) {
          // Undo: the row is gone from state, so insert it back in order.
          final tasks = [..._state.tasks, saved]
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          _set(_state.copyWith(tasks: tasks, clearError: true));
        } else {
          _replace(saved);
        }
        return saved;
      },
    );
  }

  /// Replaces one row without notifying when the value did not change.
  void _replace(Task task) {
    final index = _state.tasks.indexWhere((item) => item.id == task.id);
    if (index == -1 || _state.tasks[index] == task) {
      return;
    }
    final tasks = [..._state.tasks];
    tasks[index] = task;
    _set(_state.copyWith(tasks: tasks, clearError: true));
  }

  void _set(TaskState next) {
    _state = next;
    notifyListeners();
  }
}
