import 'package:toki_app/types/meal_type.dart';

class PlannedMeal with PlannedMealJsonSerializable {
  final String id;
  final String userId;
  @override
  final String recipeId;
  @override
  final DateTime mealDate;
  @override
  final MealType mealType;
  @override
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

  PlannedMeal copyWith({
    String? recipeId,
    MealType? mealType,
    int? servings,
    DateTime? mealDate,
  }) {
    return PlannedMeal(
      id,
      userId,
      recipeId ?? this.recipeId,
      mealDate ?? this.mealDate,
      mealType ?? this.mealType,
      servings ?? this.servings,
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

class PlannedMealCreateInput with PlannedMealJsonSerializable {
  @override
  final String recipeId;
  @override
  final DateTime mealDate;
  @override
  final MealType mealType;
  @override
  final int servings;

  PlannedMealCreateInput(
    this.recipeId,
    this.mealDate,
    this.mealType,
    this.servings,
  );
}

mixin PlannedMealJsonSerializable {
  String get recipeId;
  DateTime get mealDate;
  MealType get mealType;
  int get servings;

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'meal_date': mealDate.toIso8601String(),
      'meal_type': mealType.toString(),
      'servings': servings,
    };
  }
}
