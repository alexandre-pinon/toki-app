import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe.dart';

class RecipeDetails {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;

  RecipeDetails(this.recipe, this.ingredients, this.instructions);

  RecipeDetails.fromJson(dynamic json)
      : recipe = Recipe.fromJson(json['recipe']),
        ingredients = (json['ingredients'] as List<dynamic>)
            .map(Ingredient.fromJson)
            .toList(),
        instructions = (json['instructions'] as List<dynamic>)
            .map(Instruction.fromJson)
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'recipe': recipe.toJson(),
      'ingredients':
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions':
          instructions.map((instruction) => instruction.toJson()).toList(),
    };
  }
}
