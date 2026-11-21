import 'package:hive_ce/hive.dart';

import '../domain/task.dart';

/// Hand-written adapter so [Task] stays free of Hive imports.
///
/// Register it once before opening a box:
/// `Hive.registerAdapter(TaskAdapter());`
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++)
        reader.readByte(): reader.read(),
    };

    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      category: TaskCategory.values[fields[3] as int],
      status: TaskStatus.values[fields[4] as int],
      dueDate: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      isSynced: fields[7] as bool,
      updatedAt: fields[8] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fields[8] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category.index)
      ..writeByte(4)
      ..write(obj.status.index)
      ..writeByte(5)
      ..write(obj.dueDate.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.updatedAt?.millisecondsSinceEpoch);
  }
}
