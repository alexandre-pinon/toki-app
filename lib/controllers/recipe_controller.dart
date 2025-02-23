import 'package:flutter/material.dart';
import 'package:toki_app/models/recipe.dart';

class RecipeController {
  final TextEditingController titleController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final ValueNotifier<int> servingsController;
  final TextEditingController sourceUrlController;
  final TextEditingController imageUrlController;

  const RecipeController({
    required this.titleController,
    required this.prepTimeController,
    required this.cookTimeController,
    required this.servingsController,
    required this.sourceUrlController,
    required this.imageUrlController,
  });

  factory RecipeController.fromRecipe(Recipe recipe) => RecipeController(
        titleController: TextEditingController(text: recipe.title),
        prepTimeController: TextEditingController(
          text: recipe.prepTime?.toString() ?? '',
        ),
        cookTimeController: TextEditingController(
          text: recipe.cookTime?.toString() ?? '',
        ),
        servingsController: ValueNotifier(recipe.servings),
        sourceUrlController:
            TextEditingController(text: recipe.sourceUrl ?? ''),
        imageUrlController: TextEditingController(text: recipe.imageUrl ?? ''),
      );

  factory RecipeController.empty() => RecipeController(
        titleController: TextEditingController(),
        prepTimeController: TextEditingController(),
        cookTimeController: TextEditingController(),
        servingsController: ValueNotifier(1),
        sourceUrlController: TextEditingController(),
        imageUrlController: TextEditingController(),
      );

  RecipeCreateInput get value => RecipeCreateInput(
        title: titleController.text.trim(),
        prepTime: int.tryParse(prepTimeController.text),
        cookTime: int.tryParse(cookTimeController.text),
        servings: servingsController.value,
        sourceUrl: sourceUrlController.text.isEmpty
            ? null
            : sourceUrlController.text.trim(),
        imageUrl: imageUrlController.text.isEmpty
            ? null
            : imageUrlController.text.trim(),
      );

  void dispose() {
    titleController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    servingsController.dispose();
    sourceUrlController.dispose();
    imageUrlController.dispose();
  }
}
