import 'package:flutter/material.dart';
import 'package:toki_app/hive/types/unit_type.dart';
import 'package:toki_app/models/ingredient.dart';

class IngredientController {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final ValueNotifier<UnitType?> unitController;

  const IngredientController({
    required this.nameController,
    required this.quantityController,
    required this.unitController,
  });

  factory IngredientController.fromIngredient(Ingredient ingredient) =>
      IngredientController(
        nameController: TextEditingController(text: ingredient.name),
        quantityController: TextEditingController(
          text: ingredient.quantity?.toString() ?? '',
        ),
        unitController: ValueNotifier(ingredient.unit),
      );

  factory IngredientController.empty() => IngredientController(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        unitController: ValueNotifier(null),
      );

  Ingredient get value => Ingredient(
        nameController.text.trim().toLowerCase(), // sanitize for aggregation
        double.tryParse(quantityController.text),
        unitController.value,
      );

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}
