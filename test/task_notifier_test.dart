import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_example/core/error/result.dart';
import 'package:offline_example/features/tasks/domain/task.dart';
import 'package:offline_example/features/tasks/domain/task_repository.dart';
import 'package:offline_example/features/tasks/presentation/task_notifier.dart';
import 'package:offline_example/features/tasks/presentation/task_state.dart';

import 'fixtures.dart';

class _MockRepository extends Mock implements TaskRepository {}

void main() {
  late _MockRepository repository;
  late TaskNotifier notifier;

  setUpAll(() {
    registerFallbackValue(sampleTask());
  });

  setUp(() {
    repository = _MockRepository();
    notifier = TaskNotifier(repository);
  });

  void stubLoad(List<Task> tasks) {
    when(() => repository.loadTasks()).thenAnswer(
      (_) async => Success<List<Task>>(tasks),
    );
  }

  void stubSave() {
    when(() => repository.saveTask(any())).thenAnswer((invocation) async {
      final task = invocation.positionalArguments.single as Task;
      return Success<Task>(task);
    });
  }

  test('load sets tasks and clears the loading flag', () async {
    final task = sampleTask();
    stubLoad([task]);

    await notifier.load();

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.tasks, equals([task]));
    expect(notifier.state.error, isNull);
  });

  test('toggle marks the task completed and unsynced', () async {
    final task = sampleTask();
    stubLoad([task]);
    stubSave();
    await notifier.load();

    final updated = await notifier.toggle(task);

    expect(updated?.isCompleted, isTrue);
    expect(updated?.isSynced, isFalse);
    expect(notifier.state.tasks.single.isCompleted, isTrue);
  });

  test('filter and query both drive visibleTasks', () async {
    final first = sampleTask(id: '1', title: 'Buy office supplies');
    final second = sampleTask(
      id: '2',
      title: 'Book flights',
      status: TaskStatus.completed,
    );
    stubLoad([first, second]);
    await notifier.load();

    notifier.setFilter(TaskFilter.pending);
    expect(notifier.state.visibleTasks, equals([first]));

    notifier.setFilter(TaskFilter.all);
    notifier.search('flight');
    expect(notifier.state.visibleTasks, equals([second]));

    notifier.search('');
    expect(notifier.state.visibleTasks, hasLength(2));
  });

  test('syncPending clears unsynced flags', () async {
    final task = sampleTask(isSynced: false);
    stubLoad([task]);
    stubSave();
    when(() => repository.syncPending()).thenAnswer(
      (_) async => const Success<int>(1),
    );
    await notifier.load();

    await notifier.syncPending();

    expect(notifier.state.isSyncing, isFalse);
    expect(notifier.state.unsyncedCount, 0);
    expect(notifier.state.lastSyncedCount, 1);
  });
}
