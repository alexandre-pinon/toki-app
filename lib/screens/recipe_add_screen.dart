import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_2_screen.dart';
import 'package:toki_app/widgets/recipe_form.dart';

class RecipeAddScreen extends StatelessWidget {
  final _titleController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = ValueNotifier(0);
  final _ingredientControllers = <IngredientController>[];
  final _instructionControllers = <TextEditingController>[];

  RecipeAddScreen({super.key});

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
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await mealCreationProvider.createAndSetRecipe(recipeDetails);
      await weeklyMealsProvider.fetchMeals();
      navigator.push(
        MaterialPageRoute(builder: (context) => AddMealStep2Screen()),
      );
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
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
    );
  }
}
