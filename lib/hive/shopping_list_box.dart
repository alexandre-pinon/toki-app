import 'package:hive_flutter/hive_flutter.dart';
import 'package:toki_app/hive/types/shopping_list_item.dart';

class ShoppingListBox {
  static const String boxName = 'shopping_list';

  static Future<Box<ShoppingListItem>> openBox() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShoppingListItemAdapter());
    }
    return await Hive.openBox<ShoppingListItem>(boxName);
  }
}
