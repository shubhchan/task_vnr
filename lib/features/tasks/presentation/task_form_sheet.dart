import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/task.dart';

/// Modal form for creating and editing a task.
/// Returns the saved [Task] to the caller through the bottom sheet result.
class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.task});

  final Task? task;

  static Future<Task?> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet<Task?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _date;
  late DateTime _dueDate;
  late TaskCategory _category;

  @override
  void initState() {
    super.initState();
    final existing = widget.task;
    _title = TextEditingController(text: existing?.title ?? '');
    _amount = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(0),
    );
    _dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _date = TextEditingController(text: DateFormat.yMMMd().format(_dueDate));
    _category = existing?.category ?? TaskCategory.work;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && context.mounted) {
      setState(() {
        _dueDate = picked;
        _date.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.task;
    final task = Task(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      amount: double.parse(_amount.text.replaceAll(',', '')),
      dueDate: _dueDate,
      createdAt: existing?.createdAt ?? now,
      category: _category,
      status: existing?.status ?? TaskStatus.pending,
      isSynced: existing?.isSynced ?? false,
      updatedAt: existing?.updatedAt,
    );
    Navigator.of(context).pop<Task>(task);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task == null ? 'New task' : 'Edit task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                autofocus: widget.task == null,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.task_alt_outlined),
                ),
                validator: (value) {
                  final title = value?.trim() ?? '';
                  if (title.isEmpty) {
                    return 'Enter a title';
                  }
                  if (title.length < 3) {
                    return 'Use at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', ''),
                  );
                  if (parsed == null) {
                    return 'Enter a valid amount';
                  }
                  if (parsed < 0) {
                    return 'Amount cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Text('Category', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final category in TaskCategory.values)
                    ChoiceChip(
                      label: Text(_capitalize(category.name)),
                      selected: _category == category,
                      onSelected: (_) {
                        setState(() => _category = category);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save task')),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
