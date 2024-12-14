import 'package:toki_app/types/cuisine_type.dart';

class Recipe {
  final String id;
  final String userId;
  final String title;
  final int? prepTime;
  final int? cookTime;
  final int servings;
  final String? sourceUrl;
  final String? imageUrl;
  final CuisineType? cuisineType;
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
