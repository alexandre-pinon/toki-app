import 'dart:convert';

import 'package:toki_app/models/imported_recipe.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/services/api_client.dart';

class RecipeService {
  static const basePath = '/recipes';
  final ApiClient apiClient;

  RecipeService({required this.apiClient});

  Future<List<Recipe>> fetchRecipes() async {
    final response = await apiClient.get(basePath);

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve recipes for the moment');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map(Recipe.fromJson).toList();
  }

  Future<RecipeDetails> fetchRecipeDetails(String id) async {
    final response = await apiClient.get('$basePath/$id');

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve this recipe for the moment');
    }

    final json = jsonDecode(response.body);
    return RecipeDetails.fromJson(json);
  }

  Future<RecipeDetails> createRecipe(RecipeDetailsCreateInput input) async {
    final response = await apiClient.post(
      basePath,
      body: input.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception('Cannot create a new recipe for the moment');
    }

    final json = jsonDecode(response.body);
    return RecipeDetails.fromJson(json);
  }

  Future<RecipeDetails> updateRecipe(RecipeDetails recipeDetails) async {
    final response = await apiClient.put(
      '$basePath/${recipeDetails.recipe.id}',
      body: recipeDetails.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot update this recipe for the moment');
    }

    final json = jsonDecode(response.body);
    return RecipeDetails.fromJson(json);
  }

  Future<void> deleteRecipe(String recipeId) async {
    final response = await apiClient.delete('$basePath/$recipeId');

    if (response.statusCode != 204) {
      throw Exception('Cannot delete this recipe for the moment');
    }
  }

  Future<ImportedRecipe> importRecipe(String recipeUrl) async {
    final response = await apiClient.post(
      '$basePath/import',
      body: {'url': recipeUrl},
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot import recipe for the moment');
    }

    final json = jsonDecode(response.body);
    return ImportedRecipe.fromJson(json);
  }
}
