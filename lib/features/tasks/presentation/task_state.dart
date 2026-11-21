import 'package:equatable/equatable.dart';

import '../domain/task.dart';

/// Which status the list is showing.
enum TaskFilter { all, pending, completed }

/// Immutable snapshot of the tasks screen.
class TaskState extends Equatable {
  const TaskState({
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.query = '',
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.lastSyncedCount,
  });

  final List<Task> tasks;
  final TaskFilter filter;
  final String query;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final int? lastSyncedCount;

  /// Tasks after applying the status filter and the search query.
  List<Task> get visibleTasks {
    final term = query.trim().toLowerCase();
    return tasks
        .where((task) {
          final matchesFilter = switch (filter) {
            TaskFilter.all => true,
            TaskFilter.pending => task.isPending,
            TaskFilter.completed => task.isCompleted,
          };
          final matchesQuery =
              term.isEmpty || task.title.toLowerCase().contains(term);
          return matchesFilter && matchesQuery;
        })
        .toList(growable: false);
  }

  double get totalSpent => tasks.fold(0.0, (sum, task) => sum + task.amount);

  double get pendingAmount => tasks
      .where((task) => task.isPending)
      .fold(0.0, (sum, task) => sum + task.amount);

  int get pendingCount => tasks.where((task) => task.isPending).length;

  int get unsyncedCount => tasks.where((task) => !task.isSynced).length;

  bool get isEmpty => tasks.isEmpty;

  TaskState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    String? query,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    bool clearError = false,
    int? lastSyncedCount,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : error ?? this.error,
      lastSyncedCount: lastSyncedCount ?? this.lastSyncedCount,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    filter,
    query,
    isLoading,
    isSyncing,
    error,
    lastSyncedCount,
  ];
}
