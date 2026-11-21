import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';

import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/sync/data/sync_service.dart';
import '../../features/tasks/data/task_local_datasource.dart';
import '../../features/tasks/data/task_remote_datasource.dart';
import '../../features/tasks/data/task_repository_impl.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../network/dio_client.dart';
import '../storage/hive_setup.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything once at startup.
/// Tests can call this with fakes, or register their own instances directly.
Future<void> configureDependencies() async {
  if (getIt.isRegistered<TaskRepository>()) {
    return;
  }

  final taskBox = await HiveSetup.openTaskBox();

  getIt
    ..registerSingleton<Box<Task>>(taskBox)
    ..registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSource(getIt<Box<Task>>()),
    )
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<SyncService>(() => SyncService(Connectivity()))
    ..registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        local: getIt<TaskLocalDataSource>(),
        remote: getIt<TaskRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthLocalDataSource>()),
    );
}
