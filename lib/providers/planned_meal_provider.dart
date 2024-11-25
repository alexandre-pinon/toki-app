import 'package:flutter/material.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/services/planned_meal_service.dart';

class PlannedMealProvider with ChangeNotifier {
  final PlannedMealService _plannedMealService;

  PlannedMealProvider(this._plannedMealService);

  List<PlannedMeal> _meals = [];
  List<PlannedMeal> get meals => _meals;

  Future<void> fetchWeeklyPlannedMeals(
    DateTime from,
    DateTime to,
  ) async {
    _meals = await _plannedMealService.fetchWeeklyPlannedMeals(from, to);
    notifyListeners();
  }
}
