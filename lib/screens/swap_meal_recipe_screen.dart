import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/hive/types/weekday.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/widgets/recipe_list.dart';

class SwapMealRecipeScreen extends StatelessWidget {
  final PlannedMeal meal;

  const SwapMealRecipeScreen(this.meal, {super.key});

  Future<void> _swapMealRecipe({
    required BuildContext context,
    required String recipeId,
  }) async {
    final updatedMeal = meal.copyWith(recipeId: recipeId);

    final mealProvider = context.read<MealProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final navigator = Navigator.of(context);

    await mealProvider.updateMeal(updatedMeal);
    await Future.wait([
      mealProvider.fetchRecipeDetails(recipeId),
      weeklyMealsProvider.fetchMeals(),
    ]);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Swap ${Weekday.fromDatetimeWeekday(meal.mealDate.weekday)}\'s ${meal.mealType} recipe',
        ),
      ),
      body: RecipeList(onTapCard: _swapMealRecipe),
    );
  }
}
