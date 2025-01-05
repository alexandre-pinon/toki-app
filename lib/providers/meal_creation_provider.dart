import 'package:flutter/material.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/services/recipe_service.dart';
import 'package:toki_app/types/meal_type.dart';

class MealCreationProvider with ChangeNotifier {
  final PlannedMealService mealService;
  final RecipeService recipeService;

  MealCreationProvider({
    required this.mealService,
    required this.recipeService,
  });

  String? _recipeId;
  DateTime? _mealDate;
  MealType? _mealType;
  int? _servings;

  void setRecipeId(String recipeId) {
    _recipeId = recipeId;
    notifyListeners();
  }

  void setMealDate(DateTime mealDate) {
    _mealDate = mealDate;
    notifyListeners();
  }

  void setMealType(MealType mealType) {
    _mealType = mealType;
    notifyListeners();
  }

  void setServings(int servings) {
    _servings = servings;
    notifyListeners();
  }

  Future<void> createMeal() async {
    if (!_hasAllDataRequired()) {
      throw Exception('Missing meal data. Please restart creation flow');
    }

    final input = PlannedMealCreateInput(
      _recipeId!,
      _mealDate!,
      _mealType!,
      _servings!,
    );
    await mealService.createPlannedMeal(input);

    _resetData();
  }

  Future<void> createAndSetRecipe(RecipeDetailsCreateInput input) async {
    final recipeDetails = await recipeService.createRecipe(input);
    setRecipeId(recipeDetails.recipe.id);
  }

  bool _hasAllDataRequired() {
    return _recipeId != null &&
        _mealDate != null &&
        _mealType != null &&
        _servings != null;
  }

  void _resetData() {
    _recipeId = null;
    _mealDate = null;
    _mealType = null;
    _servings = null;
    notifyListeners();
  }
}
