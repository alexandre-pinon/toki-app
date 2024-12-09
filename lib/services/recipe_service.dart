import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/repositories/token_repository.dart';

class RecipeService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  RecipeService({required this.baseUrl, required this.tokenRepository});

  Future<RecipeDetails> fetchRecipeDetails(String id) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      return throw Unauthenticated();
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
}
