import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_notifier.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/sync/data/sync_service.dart';
import 'features/sync/presentation/connectivity_notifier.dart';
import 'features/tasks/domain/task_repository.dart';
import 'features/tasks/presentation/task_notifier.dart';

class OfflineTrackerApp extends StatelessWidget {
  const OfflineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskNotifier(getIt<TaskRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final notifier = ConnectivityNotifier(
              syncService: getIt<SyncService>(),
              taskNotifier: context.read<TaskNotifier>(),
            );
            unawaited(notifier.start());
            return notifier;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(getIt<AuthRepository>())..checkSession(),
        ),
      ],
      child: MaterialApp(
        title: 'Offline Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthNotifier, AuthStatus>(
      (notifier) => notifier.state.status,
    );

    return switch (status) {
      AuthStatus.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const _HomePlaceholder(),
    };
  }
}

// Temporary shell. The task list and dashboard replace this in the next step.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Tracker'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthNotifier>().logout(),
          ),
        ],
      ),
      body: const Center(child: Text('Tasks and dashboard coming next')),
    );
  }
}
