import 'package:toki_app/types/unit_type.dart';

class Ingredient {
  final String id;
  final String recipeId;
  final String name;
  final double? quantity;
  final UnitType? unit;

  Ingredient(
    this.id,
    this.recipeId,
    this.name,
    this.quantity,
    this.unit,
  );

  Ingredient.fromJson(dynamic json)
      : id = json['id'],
        recipeId = json['recipe_id'],
        name = json['name'],
        quantity = json['quantity'],
        unit = json['unit'] != null
            ? UnitTypeExtension.fromString(json['unit'])
            : null;
}
