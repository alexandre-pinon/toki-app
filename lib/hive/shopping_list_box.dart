import 'package:hive_flutter/hive_flutter.dart';
import 'package:toki_app/hive/types/shopping_list_item.dart';

class ShoppingListBox {
  static const String boxName = 'shopping_list';

  static Future<Box<ShoppingListItem>> openBox() async {
    return await Hive.openBox<ShoppingListItem>(boxName);
  }
}
