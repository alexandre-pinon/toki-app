import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/repositories/token_repository.dart';

class AuthService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  AuthService({required this.baseUrl, required this.tokenRepository});

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    switch (response.statusCode) {
      case 200:
        final responseBody = jsonDecode(response.body);
        await tokenRepository.saveTokens(
          responseBody['access_token'],
          responseBody['refresh_token'],
        );
      case 401:
        throw InvalidCredentials();
      default:
        throw Exception('Login failed');
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode(
        {'name': fullName, 'email': email, 'password': password},
      ),
    );

    switch (response.statusCode) {
      case 201:
        return;
      case 409:
        throw EmailAlreadyExist();
      default:
        throw Exception('Register failed');
    }
  }

  Future<void> logout() async {
    await tokenRepository.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await tokenRepository.getAccessToken();
    return accessToken != null;
  }
}
