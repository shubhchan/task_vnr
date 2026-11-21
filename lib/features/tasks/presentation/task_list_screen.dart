import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../domain/task.dart';
import 'task_form_sheet.dart';
import 'task_notifier.dart';
import 'task_state.dart';
import 'widgets/task_tile.dart';

/// Task list with debounced search, status filters, swipe-delete and undo.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(duration: AppConstants.searchDebounce);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  Future<void> _openForm({Task? task}) async {
    final notifier = context.read<TaskNotifier>();
    final saved = await TaskFormSheet.show(context, task: task);
    if (saved == null || !mounted) {
      return;
    }
    await notifier.save(saved);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskNotifier>().state;
    final notifier = context.read<TaskNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: state.isSyncing ? null : notifier.syncPending,
            icon: const Icon(Icons.sync_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune_outlined),
              ),
              onChanged: (value) {
                _debouncer.run(() => notifier.search(value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final filter in TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_capitalize(filter.name)),
                      selected: state.filter == filter,
                      onSelected: (_) => notifier.setFilter(filter),
                    ),
                  ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _buildList(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildList(TaskState state, TaskNotifier notifier) {
    if (state.isLoading && state.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tasks yet. Tap + to add your first one.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.visibleTasks.isEmpty) {
      return const Center(child: Text('No tasks match your search.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: state.visibleTasks.length,
      itemBuilder: (context, index) {
        final task = state.visibleTasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) {
            notifier.delete(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => notifier.restore(task),
                ),
              ),
            );
          },
          child: TaskTile(
            task: task,
            onToggle: () => notifier.toggle(task),
            onEdit: () => _openForm(task: task),
          ),
        );
      },
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
