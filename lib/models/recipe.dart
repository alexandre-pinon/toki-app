import 'package:toki_app/types/cuisine_type.dart';

class Recipe with RecipeJsonSerializable {
  final String id;
  final String userId;
  @override
  final String title;
  @override
  final int? prepTime;
  @override
  final int? cookTime;
  @override
  final int servings;
  @override
  final String? sourceUrl;
  @override
  final String? imageUrl;
  @override
  final CuisineType? cuisineType;
  @override
  final int? rating;

  Recipe(
    this.id,
    this.userId,
    this.title,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.sourceUrl,
    this.imageUrl,
    this.cuisineType,
    this.rating,
  );

  Recipe.fromJson(dynamic json)
      : id = json['id'],
        userId = json['user_id'],
        title = json['title'],
        prepTime = json['prep_time'],
        cookTime = json['cook_time'],
        servings = json['servings'],
        sourceUrl = json['source_url'],
        imageUrl = json['image_url'],
        cuisineType = json['cuisine_type'] != null
            ? CuisineTypeExtension.fromString(json['cuisine_type'])
            : null,
        rating = json['rating'];

  Recipe copyWith({
    required String title,
    int? prepTime,
    int? cookTime,
    required int servings,
    String? sourceUrl,
    String? imageUrl,
  }) {
    return Recipe(
      id,
      userId,
      title,
      prepTime,
      cookTime,
      servings,
      sourceUrl,
      imageUrl,
      cuisineType,
      rating,
    );
  }
}

class RecipeCreateInput with RecipeJsonSerializable {
  @override
  final String title;
  @override
  final int? prepTime;
  @override
  final int? cookTime;
  @override
  final int servings;
  @override
  final String? sourceUrl;
  @override
  final String? imageUrl;
  @override
  final CuisineType? cuisineType;
  @override
  final int? rating;

  RecipeCreateInput({
    required this.title,
    this.prepTime,
    this.cookTime,
    required this.servings,
    this.sourceUrl,
    this.imageUrl,
    this.cuisineType,
    this.rating,
  });
}

mixin RecipeJsonSerializable {
  String get title;
  int? get prepTime;
  int? get cookTime;
  int get servings;
  String? get sourceUrl;
  String? get imageUrl;
  CuisineType? get cuisineType;
  int? get rating;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'source_url': sourceUrl,
      'image_url': imageUrl,
      'cuisine_type': cuisineType.toString(),
      'rating': rating,
    };
  }
}
