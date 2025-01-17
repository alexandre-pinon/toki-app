import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/shopping_list_item.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/shopping_list_provider.dart';
import 'package:toki_app/types/string.dart';
import 'package:toki_app/types/unit_type.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:toki_app/widgets/shopping_list_item_form.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchItems);
  }

  Future<void> _fetchItems() async {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await shoppingListProvider.fetchInitialItems();
    } on Unauthenticated {
      await authProvider.logout();
    }
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

  Future<void> _removeShoppingListItem(BuildContext context) async {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await shoppingListProvider.removeItem(item.ids[0]);
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
    var subtitle = '';
    if (formattedQuantity.isNotEmpty) {
      subtitle += '$formattedQuantity ';
    }
    if (formattedUnit.isNotEmpty) {
      subtitle += '$formattedUnit ';
    }

    return Dismissible(
      key: ValueKey(item.ids),
      direction: item.canBeDeleted
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (direction) {
        return showConfirmationDialog(
          context: context,
          title: 'Remove ${item.name}?',
        );
      },
      onDismissed: (direction) {
        _removeShoppingListItem(context);
      },
      dismissThresholds: {DismissDirection.endToStart: 0.2},
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        child: Icon(Icons.delete),
      ),
      child: ListTile(
        tileColor: item.checked ? Colors.grey[300] : null,
        leading: Checkbox(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          value: item.checked,
          onChanged: (_) {
            _toggleItemCheck(context);
          },
        ),
        title: Text(item.name.capitalize()),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        onTap: () {
          item.canBeEdited
              ? showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ShoppingListItemForm(item: item),
                )
              : _toggleItemCheck(context);
        },
        trailing: formattedWeekday.isNotEmpty
            ? Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(formattedWeekday),
              )
            : null,
      ),
    );
  }
}
