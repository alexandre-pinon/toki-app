import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/repositories/token_repository.dart';

class PlannedMealService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  PlannedMealService({required this.baseUrl, required this.tokenRepository});

  Future<List<PlannedMeal>> fetchWeeklyPlannedMeals(
    DateTime from,
    DateTime to,
  ) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse(baseUrl).replace(
        queryParameters: {
          'start_date': from.toString(),
          'end_date': to.toString(),
        },
      ),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch weekly planned meals failed');
    }

    final List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map(PlannedMeal.fromJson).toList();
  }
}
