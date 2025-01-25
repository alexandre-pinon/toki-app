import 'package:hive_flutter/hive_flutter.dart';
import 'package:toki_app/hive/types/shopping_list_item.dart';

part 'pending_task.g.dart';

@HiveType(typeId: 3)
enum TaskType {
  @HiveField(0)
  check,
  @HiveField(1)
  uncheck,
}

@HiveType(typeId: 4)
class PendingTask {
  @HiveField(0)
  final TaskType type;
  @HiveField(1)
  final ShoppingListItem item;

  PendingTask({
    required this.type,
    required this.item,
  });
}
