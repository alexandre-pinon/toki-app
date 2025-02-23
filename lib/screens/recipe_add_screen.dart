import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/controllers/recipe_controller.dart';
import 'package:toki_app/models/imported_recipe.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/providers/recipes_provider.dart';
import 'package:toki_app/services/recipe_service.dart';
import 'package:toki_app/widgets/recipe_form.dart';

class RecipeAddScreen extends StatefulWidget {
  const RecipeAddScreen({super.key});

  @override
  State<RecipeAddScreen> createState() => _RecipeAddScreenState();
}

class _RecipeAddScreenState extends State<RecipeAddScreen> {
  final _recipeController = RecipeController.empty();
  final _ingredientControllers = <IngredientController>[];
  final _instructionControllers = <TextEditingController>[];
  final _urlController = TextEditingController();

  Future<void> _createRecipe(BuildContext context) async {
    final recipe = _recipeController.value;
    final ingredients = _ingredientControllers
        .map(
          (controller) => controller.value,
        )
        .toList();
    final instructions = _instructionControllers
        .mapIndexed(
          (index, controller) => Instruction(index + 1, controller.text),
        )
        .toList();
    final recipeDetails = RecipeDetailsCreateInput(
      recipe,
      ingredients,
      instructions,
    );

    final mealCreationProvider = context.read<MealCreationProvider>();
    final recipesProvider = context.read<RecipesProvider>();
    final navigator = Navigator.of(context);

    await mealCreationProvider.createAndSetRecipe(recipeDetails);
    await recipesProvider.fetchRecipes();
    navigator.pop();
  }

  Future<void> _importRecipe(BuildContext context) async {
    final recipeService = context.read<RecipeService>();
    final navigator = Navigator.of(context);

    final recipeDetails = await recipeService.importRecipe(
      _urlController.text.trim(),
    );
    _setRecipe(recipeDetails);
    navigator.pop();
  }

  void _setRecipe(ImportedRecipe recipe) {
    setState(() {
      if (recipe.title != null) {
        _recipeController.titleController.text = recipe.title!;
      }
      if (recipe.servings != null) {
        _recipeController.servingsController.value = recipe.servings!;
      }
      if (recipe.prepTime != null) {
        _recipeController.prepTimeController.text = recipe.prepTime!.toString();
      }
      if (recipe.cookTime != null) {
        _recipeController.cookTimeController.text = recipe.cookTime!.toString();
      }
      if (recipe.sourceUrl != null) {
        _recipeController.sourceUrlController.text = recipe.sourceUrl!;
      }
      if (recipe.imageUrl != null) {
        _recipeController.imageUrlController.text = recipe.imageUrl!;
      }
      if (recipe.ingredients.isNotEmpty) {
        _ingredientControllers.clear();
        _ingredientControllers.addAll(
          recipe.ingredients.map(IngredientController.fromIngredient),
        );
      }
      if (recipe.instructions.isNotEmpty) {
        _instructionControllers.clear();
        _instructionControllers.addAll(
          recipe.instructions.map(
            (instruction) =>
                TextEditingController(text: instruction.instruction),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add recipe'),
      ),
      body: ListView(
        children: [
          RecipeForm(
            recipeController: _recipeController,
            ingredientControllers: _ingredientControllers,
            instructionControllers: _instructionControllers,
          ),
          SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () async {
                await _createRecipe(context);
              },
              icon: Icon(Icons.check),
              label: Text('Add recipe'),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Import Recipe',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Import recipe from marmiton',
                        border: OutlineInputBorder(),
                      ),
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
                            await _importRecipe(context);
                          },
                          child: Text('Import'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.cloud_download),
      ),
    );
  }
}
