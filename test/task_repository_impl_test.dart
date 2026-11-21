import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_example/core/error/result.dart';
import 'package:offline_example/features/tasks/data/task_local_datasource.dart';
import 'package:offline_example/features/tasks/data/task_model.dart';
import 'package:offline_example/features/tasks/data/task_remote_datasource.dart';
import 'package:offline_example/features/tasks/data/task_repository_impl.dart';
import 'package:offline_example/features/tasks/domain/task.dart';
import 'package:offline_example/features/tasks/domain/task_repository.dart';

import 'fixtures.dart';

class _MockLocal extends Mock implements TaskLocalDataSource {}

class _MockRemote extends Mock implements TaskRemoteDataSource {}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late TaskRepository repository;

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    repository = TaskRepositoryImpl(local: local, remote: remote);
  });

  group('TaskRepositoryImpl', () {
    test('reads cached tasks without calling the API', () async {
      final task = sampleTask();
      when(() => local.isEmpty).thenReturn(false);
      when(() => local.readAll()).thenReturn([task]);

      final result = await repository.loadTasks();

      expect(result, isA<Success<List<Task>>>());
      expect(result.valueOrNull, equals([task]));
      verifyNever(() => remote.fetchTodos());
    });

    test('seeds the box from the API on first launch', () async {
      final model = TaskModel(id: 1, title: 'Seed task', completed: false);
      when(() => local.isEmpty).thenReturn(true);
      when(() => remote.fetchTodos()).thenAnswer(
        (_) async => Success<List<TaskModel>>([model]),
      );
      when(() => local.putAll(any<Iterable<Task>>())).thenAnswer(
        (_) async {},
      );
      when(() => local.readAll()).thenReturn([sampleTask(id: 'seed-1')]);

      final result = await repository.loadTasks();

      expect(result.valueOrNull, hasLength(1));
      verify(() => local.putAll(any<Iterable<Task>>())).called(1);
    });

    test('returns an empty list when the seed call fails', () async {
      when(() => local.isEmpty).thenReturn(true);
      when(() => remote.fetchTodos()).thenAnswer(
        (_) async => const Failure<List<TaskModel>>(NetworkFailure()),
      );
      when(() => local.readAll()).thenReturn([]);

      final result = await repository.loadTasks();

      expect(result, isA<Success<List<Task>>>());
      expect(result.valueOrNull, isEmpty);
      verifyNever(() => local.putAll(any<Iterable<Task>>()));
    });

    test('syncPending marks every pending task as synced', () async {
      final pending = sampleTask(isSynced: false);
      when(() => local.pending).thenReturn([pending]);
      when(() => local.putAll(any<Iterable<Task>>())).thenAnswer(
        (_) async {},
      );

      final result = await repository.syncPending();

      expect(result.valueOrNull, 1);
      final captured = verify(
        () => local.putAll(captureAny<Iterable<Task>>()),
      ).captured;
      final tasks = captured.single as Iterable<Task>;
      expect(tasks.single.isSynced, isTrue);
    });
  });
}
