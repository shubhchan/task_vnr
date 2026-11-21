import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_notifier.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/sync/data/sync_service.dart';
import 'features/sync/presentation/connectivity_notifier.dart';
import 'features/tasks/domain/task_repository.dart';
import 'features/tasks/presentation/task_list_screen.dart';
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
      AuthStatus.authenticated => const _HomeShell(),
    };
  }
}

/// Two-tab shell: Overview and Tasks.
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [DashboardScreen(), TaskListScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}
