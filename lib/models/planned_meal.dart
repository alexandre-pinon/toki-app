import 'package:toki_app/types/meal_type.dart';

class PlannedMeal {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime mealDate;
  final MealType mealType;
  final int servings;
  final String? title;
  final String? imageUrl;

  PlannedMeal(
    this.id,
    this.userId,
    this.recipeId,
    this.mealDate,
    this.mealType,
    this.servings,
    this.title,
    this.imageUrl,
  );

  PlannedMeal.fromJson(dynamic json)
      : id = json['id'],
        userId = json['user_id'],
        recipeId = json['recipe_id'],
        mealDate = DateTime.parse(json['meal_date'])
            .copyWith(isUtc: true), // force date parse as UTC
        mealType = MealTypeExtension.fromString(json['meal_type']),
        servings = json['servings'],
        title = json['recipe'] != null ? json['recipe']['title'] : null,
        imageUrl = json['recipe'] != null ? json['recipe']['image_url'] : null;
}
