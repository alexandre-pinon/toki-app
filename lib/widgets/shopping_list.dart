import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/shopping_list_item.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/shopping_list_provider.dart';
import 'package:toki_app/types/string.dart';
import 'package:toki_app/types/unit_type.dart';
import 'package:toki_app/types/weekday.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<void> fetchItems() async {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await shoppingListProvider.fetchItems();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final shoppingListProvider = context.watch<ShoppingListProvider>();

        if (shoppingListProvider.loading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          itemCount: shoppingListProvider.items.length,
          itemBuilder: (context, index) => ItemCard(
            item: shoppingListProvider.items[index],
            index: index,
          ),
          separatorBuilder: (context, index) => Divider(height: 0),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final int index;

  const ItemCard({super.key, required this.item, required this.index});

  Future<void> _toggleItemCheck(BuildContext context) async {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      shoppingListProvider.toggleCheckItem(index);
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  String _formatUnit(UnitType? unit) {
    return unit != null ? unit.displayName : '';
  }

  String _formatQuantity(double? quantity) {
    if (quantity == null) return '';

    return quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(1);
  }

  String _formatWeekday(Weekday? weekday) {
    return weekday != null ? weekday.minifiedDisplayName : '';
  }

  @override
  Widget build(BuildContext context) {
    final formattedUnit = _formatUnit(item.unit);
    final formattedQuantity = _formatQuantity(item.quantity);
    final formattedWeekday = _formatWeekday(item.weekday);
    final theme = Theme.of(context);

    return Container(
      color: item.checked ? Colors.grey[300] : theme.listTileTheme.tileColor,
      child: CheckboxListTile(
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        checkboxScaleFactor: 1.1,
        controlAffinity: ListTileControlAffinity.leading,
        value: item.checked,
        onChanged: (_) async {
          await _toggleItemCheck(context);
        },
        title: Text(item.name.capitalize()),
        subtitle: Text(formattedWeekday.isEmpty
            ? '$formattedQuantity $formattedUnit'
            : '$formattedQuantity $formattedUnit - $formattedWeekday'),
      ),
    );
  }
}
