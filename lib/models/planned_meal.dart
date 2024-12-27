import 'package:toki_app/types/meal_type.dart';

class PlannedMeal {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime mealDate;
  final MealType mealType;
  final int servings;

  PlannedMeal(
    this.id,
    this.userId,
    this.recipeId,
    this.mealDate,
    this.mealType,
    this.servings,
  );

  PlannedMeal.fromJson(dynamic json)
      : id = json['id'],
        userId = json['user_id'],
        recipeId = json['recipe_id'],
        mealDate = DateTime.parse(json['meal_date'])
            .copyWith(isUtc: true), // force date parse as UTC
        mealType = MealType.fromString(json['meal_type']),
        servings = json['servings'];

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'meal_date': mealDate.toIso8601String(),
      'meal_type': mealType.toString(),
      'servings': servings,
    };
  }

  PlannedMeal copyWith({
    required MealType mealType,
    required int servings,
  }) {
    return PlannedMeal(
      id,
      userId,
      recipeId,
      mealDate,
      mealType,
      servings,
    );
  }
}

class WeeklyPlannedMeal extends PlannedMeal {
  final String title;
  final String? imageUrl;

  WeeklyPlannedMeal(
    super.id,
    super.userId,
    super.recipeId,
    super.mealDate,
    super.mealType,
    super.servings,
    this.title,
    this.imageUrl,
  );

  factory WeeklyPlannedMeal.fromJson(dynamic json) {
    final meal = PlannedMeal.fromJson(json);
    final title = json['recipe']['title'];
    final imageUrl = json['recipe']['image_url'];

    return WeeklyPlannedMeal.fromMeal(meal, title, imageUrl);
  }

  factory WeeklyPlannedMeal.fromMeal(
    PlannedMeal meal,
    String title,
    String? imageUrl,
  ) {
    return WeeklyPlannedMeal(
      meal.id,
      meal.userId,
      meal.recipeId,
      meal.mealDate,
      meal.mealType,
      meal.servings,
      title,
      imageUrl,
    );
  }
}
