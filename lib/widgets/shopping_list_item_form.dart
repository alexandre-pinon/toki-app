import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/shopping_list_provider.dart';
import 'package:toki_app/types/unit_type.dart';

class ShoppingListItemForm extends StatelessWidget {
  final _ingredientController = IngredientController.empty();

  ShoppingListItemForm({super.key});

  Future<void> _createShoppingListItem(BuildContext context) async {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await shoppingListProvider.addNewItem(_ingredientController.value);
    } on Unauthenticated {
      await authProvider.logout();
    } finally {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add new item',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _ingredientController.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ingredientController.quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _ingredientController.unitController,
                  builder: (context, value, child) {
                    final items = UnitType.values
                        .map(
                          (unitType) => DropdownMenuItem(
                            value: unitType,
                            child: Text(unitType.displayName),
                          ),
                        )
                        .toList();
                    items.add(
                      DropdownMenuItem(value: null, child: Text('(none)')),
                    );

                    return DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: value,
                      items: items,
                      onChanged: (newValue) {
                        _ingredientController.unitController.value = newValue;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 12,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await _createShoppingListItem(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
