import 'package:toki_app/models/shopping_list_item.dart';
import 'package:toki_app/providers/loading_change_notifier.dart';
import 'package:toki_app/services/shopping_list_item_service.dart';

class ShoppingListProvider extends LoadingChangeNotifier {
  final ShoppingListItemService shoppingListItemService;

  ShoppingListProvider({required this.shoppingListItemService});

  List<ShoppingListItem> _items = [];
  List<ShoppingListItem> get items => _items;

  Future<void> fetchItems() async {
    await withLoading(() async {
      _items = await shoppingListItemService.fetchItems();
    });
  }

  Future<void> toggleCheckItem(int index) async {
    _items[index].checked
        ? await shoppingListItemService.uncheckItem(_items[index])
        : await shoppingListItemService.checkItem(_items[index]);
    _items = await shoppingListItemService.fetchItems();
    notifyListeners();
  }
}
