import 'package:toki_app/types/unit_type.dart';

class Ingredient {
  final String name;
  final double? quantity;
  final UnitType? unit;

  Ingredient(
    this.name,
    this.quantity,
    this.unit,
  );

  Ingredient.fromJson(dynamic json)
      : name = json['name'],
        quantity = json['quantity'],
        unit = json['unit'] != null
            ? UnitTypeExtension.fromString(json['unit'])
            : null;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit?.toString(),
    };
  }
}
