import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/widgets/recipe_form.dart';

class RecipeEditScreen extends StatefulWidget {
  final RecipeDetails recipeDetails;

  const RecipeEditScreen(this.recipeDetails, {super.key});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final ValueNotifier<int> _servingsController;
  late final List<IngredientController> _ingredientControllers;
  late final List<TextEditingController> _instructionControllers;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipeDetails.recipe;
    _titleController = TextEditingController(text: recipe.title);
    _prepTimeController = TextEditingController(
      text: recipe.prepTime?.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: recipe.cookTime?.toString() ?? '',
    );
    _servingsController = ValueNotifier(recipe.servings);
    _ingredientControllers = widget.recipeDetails.ingredients
        .map(IngredientController.fromIngredient)
        .toList();
    _instructionControllers = widget.recipeDetails.instructions
        .map(
          (instruction) => TextEditingController(text: instruction.instruction),
        )
        .toList();
  }

  Future<void> _saveData() async {
    final updatedRecipe = widget.recipeDetails.recipe.copyWith(
      title: _titleController.text.trim(),
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      servings: _servingsController.value,
    );
    final updatedIngredients = _ingredientControllers
        .map(
          (controller) => controller.value,
        )
        .toList();
    final updatedInstructions = _instructionControllers
        .mapIndexed(
          (index, controller) => Instruction(index + 1, controller.text),
        )
        .toList();
    final updatedRecipeDetails = RecipeDetails(
      updatedRecipe,
      updatedIngredients,
      updatedInstructions,
    );

    final mealProvider = context.read<MealProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await mealProvider.updateRecipe(updatedRecipeDetails);
      await weeklyMealsProvider.fetchMeals();
      navigator.pop();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.recipeDetails.recipe.title.toLowerCase()} recipe',
        ),
        actions: [
          IconButton(
            onPressed: _saveData,
            icon: Icon(Icons.save),
          )
        ],
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
          )
        ],
      ),
    );
  }
}
