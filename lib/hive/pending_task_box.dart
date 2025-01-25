import 'package:hive_flutter/hive_flutter.dart';
import 'package:toki_app/hive/types/pending_task.dart';

class PendingTaskBox {
  static const String _boxName = 'pending_task_box';

  static Future<Box<PendingTask>> openBox() async {
    return await Hive.openBox<PendingTask>(_boxName);
  }
}
