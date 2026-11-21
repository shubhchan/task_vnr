import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/tasks/data/task_adapter.dart';
import '../../features/tasks/domain/task.dart';
import '../constants/app_constants.dart';

/// Opens local boxes. Register adapters here before the box is opened.
class HiveSetup {
  const HiveSetup._();

  static Future<Box<Task>> openTaskBox() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    return Hive.openBox<Task>(AppConstants.taskBoxName);
  }
}
