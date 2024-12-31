import 'package:flutter/material.dart';
import 'package:toki_app/types/meal_type.dart';

class MealCreationProvider with ChangeNotifier {
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

  void printData() {
    print(
        'recipeId: $_recipeId, mealDate: $_mealDate, mealType: $_mealType, servings: $_servings');
  }
}
