import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/controllers/recipe_controller.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe_details.dart';
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
  late final RecipeController _recipeController;
  late final List<IngredientController> _ingredientControllers;
  late final List<TextEditingController> _instructionControllers;

  @override
  void initState() {
    super.initState();
    _recipeController =
        RecipeController.fromRecipe(widget.recipeDetails.recipe);
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
      title: _recipeController.value.title,
      prepTime: _recipeController.value.prepTime,
      cookTime: _recipeController.value.cookTime,
      servings: _recipeController.value.servings,
      sourceUrl: _recipeController.value.sourceUrl,
      imageUrl: _recipeController.value.imageUrl,
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
    final navigator = Navigator.of(context);

    await mealProvider.updateRecipe(updatedRecipeDetails);
    await weeklyMealsProvider.fetchMeals();
    navigator.pop();
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
            recipeController: _recipeController,
            ingredientControllers: _ingredientControllers,
            instructionControllers: _instructionControllers,
          )
        ],
      ),
    );
  }
}
