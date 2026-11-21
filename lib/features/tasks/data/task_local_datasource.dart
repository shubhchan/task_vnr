import 'package:hive_ce/hive.dart';

import '../domain/task.dart';

/// Thin wrapper around the Hive box.
/// Keeps Hive types out of the repository and the UI.
class TaskLocalDataSource {
  TaskLocalDataSource(this._box);

  final Box<Task> _box;

  bool get isEmpty => _box.isEmpty;

  List<Task> readAll() => _box.values.toList(growable: false);

  List<Task> get pending =>
      _box.values.where((task) => !task.isSynced).toList(growable: false);

  Future<void> put(Task task) => _box.put(task.id, task);

  Future<void> putAll(Iterable<Task> tasks) async {
    final byId = {for (final task in tasks) task.id: task};
    await _box.putAll(byId);
  }

  Future<void> delete(String id) => _box.delete(id);
}
