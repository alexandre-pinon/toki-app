import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toki_app/hive/pending_task_box.dart';
import 'package:toki_app/hive/shopping_list_box.dart';
import 'package:toki_app/hive/types/pending_task.dart';
import 'package:toki_app/hive/types/shopping_list_item.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/services/shopping_list_item_service.dart';

class ShoppingListProvider with ChangeNotifier {
  final ShoppingListItemService shoppingListItemService;
  late final Box<ShoppingListItem> _itemsBox;
  late final Box<PendingTask> _pendingTasksBox;

  ShoppingListProvider({required this.shoppingListItemService}) {
    _init();
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  List<ShoppingListItem> _items = [];
  List<ShoppingListItem> get items => _items;

  Future<void> _init() async {
    _itemsBox = await ShoppingListBox.openBox();
    _pendingTasksBox = await PendingTaskBox.openBox();

    _items = _itemsBox.values.toList()..sort();
    _isInitialized = true;
    notifyListeners();

    await resyncItems();
  }

  Future<void> resyncItems() async {
    if (!_isInitialized) {
      return;
    }

    await _retryPendingTasks();
    final items = await shoppingListItemService.fetchItems();
    _saveToLocalCache(items..sort());
  }

  Future<void> _retryPendingTasks() async {
    final pendingTasks = _pendingTasksBox.values.toList();
    final keys = _pendingTasksBox.keys.toList();
    for (final pair in IterableZip([pendingTasks, keys])) {
      final task = pair.first as PendingTask;
      final key = pair.last as int;

      try {
        switch (task.type) {
          case TaskType.check:
            await shoppingListItemService.checkItem(task.item);
            break;
          case TaskType.uncheck:
            await shoppingListItemService.uncheckItem(task.item);
            break;
        }
        _pendingTasksBox.delete(key);
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _pushPendingTask(TaskType type, ShoppingListItem item) async {
    final task = PendingTask(type: type, item: item);
    await _pendingTasksBox.add(task);
  }

  Future<void> _saveToLocalCache(List<ShoppingListItem> items) async {
    await _itemsBox.clear();
    await _itemsBox.addAll(items);
    _items = items;
    notifyListeners();
  }

  Future<void> toggleCheckItem(int index) async {
    final item = _items[index];
    final updatedItem = item.copyWith(checked: !item.checked);

    _items[index] = updatedItem;
    _items.sort();
    await _itemsBox.putAt(index, updatedItem);
    notifyListeners();

    try {
      updatedItem.checked
          ? await shoppingListItemService.checkItem(updatedItem)
          : await shoppingListItemService.uncheckItem(updatedItem);
      await resyncItems();
    } catch (e) {
      await _pushPendingTask(
        updatedItem.checked ? TaskType.check : TaskType.uncheck,
        updatedItem,
      );
    }
  }

  Future<void> addNewItem(Ingredient input) async {
    await shoppingListItemService.createItem(input);
    await resyncItems();
  }

  Future<void> editItemIngredient(
    String itemId,
    Ingredient input,
  ) async {
    await shoppingListItemService.updateItemIngredient(itemId, input);
    await resyncItems();
  }

  Future<void> removeItem(String itemId) async {
    await shoppingListItemService.deleteItem(itemId);
    await resyncItems();
  }
}
