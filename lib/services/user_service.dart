import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/user.dart';
import 'package:toki_app/repositories/token_repository.dart';

class UserService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  UserService({required this.baseUrl, required this.tokenRepository});

  Future<User> getProfile() async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Get user profile failed');
    }
  }

  Future<User> updateProfile(String name) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-type': 'application/json'
      },
      body: jsonEncode({'name': name}),
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Update user profile failed');
    }
  }
}
