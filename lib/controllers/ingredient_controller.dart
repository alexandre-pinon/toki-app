import 'package:flutter/material.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/types/unit_type.dart';

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
        nameController.text,
        double.tryParse(quantityController.text),
        unitController.value,
      );

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}
