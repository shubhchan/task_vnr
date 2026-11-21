import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/debouncer.dart';
import '../task_notifier.dart';

/// Isolated search input.
/// It does not listen to state, so screen rebuilds never reset its cursor.
class TaskSearchField extends StatefulWidget {
  const TaskSearchField({super.key});

  @override
  State<TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends State<TaskSearchField> {
  final _controller = TextEditingController();
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(duration: AppConstants.searchDebounce);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Search tasks',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.tune_outlined),
        ),
        onChanged: (value) {
          final notifier = context.read<TaskNotifier>();
          _debouncer.run(() => notifier.search(value));
        },
      ),
    );
  }
}
