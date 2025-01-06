import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';

class ImportedRecipe {
  final String? title;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final String? sourceUrl;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;

  ImportedRecipe({
    this.title,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.sourceUrl,
    this.imageUrl,
    this.ingredients = const [],
    this.instructions = const [],
  });

  ImportedRecipe.fromJson(dynamic json)
      : title = json['title'],
        prepTime = json['prep_time'],
        cookTime = json['cook_time'],
        servings = json['servings'],
        sourceUrl = json['source_url'],
        imageUrl = json['image_url'],
        ingredients = (json['ingredients'] as List<dynamic>)
            .map(Ingredient.fromJson)
            .toList(),
        instructions = (json['instructions'] as List<dynamic>)
            .map(Instruction.fromJson)
            .toList();
}
