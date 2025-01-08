import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/imported_recipe.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/auth_provider.dart';
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
  final _titleController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = ValueNotifier(1);
  final _ingredientControllers = <IngredientController>[];
  final _instructionControllers = <TextEditingController>[];
  final _urlController = TextEditingController();

  Future<void> _createRecipe(BuildContext context) async {
    final recipe = RecipeCreateInput(
      title: _titleController.text,
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      servings: _servingsController.value,
    );
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
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await mealCreationProvider.createAndSetRecipe(recipeDetails);
      await recipesProvider.fetchRecipes();
      navigator.pop();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  Future<void> _importRecipe(BuildContext context) async {
    final recipeService = context.read<RecipeService>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      final recipeDetails = await recipeService.importRecipe(
        _urlController.text.trim(),
      );
      _setRecipe(recipeDetails);
    } on Unauthenticated {
      await authProvider.logout();
    } finally {
      navigator.pop();
    }
  }

  void _setRecipe(ImportedRecipe recipe) {
    setState(() {
      if (recipe.title != null) {
        _titleController.text = recipe.title!;
      }
      if (recipe.servings != null) {
        _servingsController.value = recipe.servings!;
      }
      if (recipe.prepTime != null) {
        _prepTimeController.text = recipe.prepTime!.toString();
      }
      if (recipe.cookTime != null) {
        _cookTimeController.text = recipe.cookTime!.toString();
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add recipe'),
      ),
      body: ListView(
        children: [
          RecipeForm(
            titleController: _titleController,
            prepTimeController: _prepTimeController,
            cookTimeController: _cookTimeController,
            servingsController: _servingsController,
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
            builder: (context) => Padding(
              padding: EdgeInsets.all(20.0),
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
                      hintText: 'https://super-delicious-recipe.com',
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
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.cloud_download),
      ),
    );
  }
}
