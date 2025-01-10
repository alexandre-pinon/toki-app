import 'dart:convert';

import 'package:toki_app/errors/meal_already_exist_error.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/services/api_client.dart';
import 'package:toki_app/types/weekday.dart';

class PlannedMealService {
  static const basePath = '/planned-meals';
  final ApiClient apiClient;

  PlannedMealService({required this.apiClient});

  Future<List<WeeklyPlannedMeal>> fetchWeeklyPlannedMeals(
    DateTime from,
    DateTime to,
  ) async {
    final queryParameters = {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    };
    final response = await apiClient.get(
      Uri.parse(basePath).replace(queryParameters: queryParameters).toString(),
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve weekly meals for the moment');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map(WeeklyPlannedMeal.fromJson).toList();
  }

  Future<PlannedMeal> fetchPlannedMeal(String id) async {
    final response = await apiClient.get('$basePath/$id');

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve this meal for the moment');
    }

    final dynamic json = jsonDecode(response.body);
    return PlannedMeal.fromJson(json);
  }

  Future<PlannedMeal> createPlannedMeal(PlannedMealCreateInput input) async {
    final response = await apiClient.post(
      basePath,
      body: input.toJson(),
    );

    switch (response.statusCode) {
      case 201:
        final json = jsonDecode(response.body);
        return PlannedMeal.fromJson(json);
      case 409:
        throw MealAlreadyExist(
          Weekday.fromDatetimeWeekday(input.mealDate.weekday),
          input.mealType,
        );
      default:
        throw Exception('Cannot create a new meal for the moment');
    }
  }

  Future<PlannedMeal> updatePlannedMeal(PlannedMeal meal) async {
    final response = await apiClient.put(
      '$basePath/${meal.id}',
      body: meal.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot update this meal for the moment');
    }

    final json = jsonDecode(response.body);
    return PlannedMeal.fromJson(json);
  }

  Future<void> deletePlannedMeal(String mealId) async {
    final response = await apiClient.delete('$basePath/$mealId');

    if (response.statusCode != 204) {
      throw Exception('Cannot delete this meal for the moment');
    }
  }
}
