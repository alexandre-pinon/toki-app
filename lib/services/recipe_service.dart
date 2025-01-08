import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/imported_recipe.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/repositories/token_repository.dart';

class RecipeService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  RecipeService({required this.baseUrl, required this.tokenRepository});

  Future<List<Recipe>> fetchRecipes() async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    switch (response.statusCode) {
      case 200:
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map(Recipe.fromJson).toList();
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Fetch recipes failed');
    }
  }

  Future<RecipeDetails> fetchRecipeDetails(String id) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch recipe details failed');
    }

    final json = jsonDecode(response.body);

    return RecipeDetails.fromJson(json);
  }

  Future<RecipeDetails> createRecipe(RecipeDetailsCreateInput input) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-type': 'application/json'
      },
      body: jsonEncode(input.toJson()),
    );

    switch (response.statusCode) {
      case 201:
        final json = jsonDecode(response.body);
        return RecipeDetails.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Create recipe failed');
    }
  }

  Future<RecipeDetails> updateRecipe(RecipeDetails recipeDetails) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${recipeDetails.recipe.id}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-type': 'application/json'
      },
      body: jsonEncode(recipeDetails.toJson()),
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return RecipeDetails.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Update recipe failed');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$recipeId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    switch (response.statusCode) {
      case 204:
        return;
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Delete recipe failed');
    }
  }

  Future<ImportedRecipe> importRecipe(String recipeUrl) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/import'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-type': 'application/json'
      },
      body: jsonEncode({'url': recipeUrl}),
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return ImportedRecipe.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Import recipe failed');
    }
  }
}
