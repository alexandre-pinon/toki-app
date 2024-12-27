import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/repositories/token_repository.dart';

class PlannedMealService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  PlannedMealService({required this.baseUrl, required this.tokenRepository});

  Future<List<WeeklyPlannedMeal>> fetchWeeklyPlannedMeals(
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

    switch (response.statusCode) {
      case 200:
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map(WeeklyPlannedMeal.fromJson).toList();
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Fetch weekly planned meals failed');
    }
  }

  Future<PlannedMeal> fetchPlannedMeal(String id) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    switch (response.statusCode) {
      case 200:
        final dynamic json = jsonDecode(response.body);
        return PlannedMeal.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Fetch planned meal $id failed');
    }
  }

  Future<PlannedMeal> updatePlannedMeal(PlannedMeal meal) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${meal.id}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-type': 'application/json'
      },
      body: jsonEncode(meal.toJson()),
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return PlannedMeal.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Update planned meal failed');
    }
  }
}
