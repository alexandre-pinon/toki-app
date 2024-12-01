import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
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
      throw Unauthenticated();
    }

    final queryParameters = {
      'start_date': from.toIso8601String(),
      'end_date': to.toIso8601String(),
    };
    final response = await http.get(
      Uri.parse(baseUrl).replace(queryParameters: queryParameters),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch weekly planned meals failed');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);

    return jsonList.map(PlannedMeal.fromJson).toList();
  }
}
