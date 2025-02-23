import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/repositories/token_repository.dart';

class AuthService {
  final String baseUrl;
  static const basePath = '/auth';
  final TokenRepository tokenRepository;
  // no need refresh mechanism here, no need to use ApiClient
  final http.Client httpClient = http.Client();

  AuthService({required this.baseUrl, required this.tokenRepository});

  Future<void> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl$basePath/login'),
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
        throw Exception(
          'Can\'t log you in for the moment',
        );
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl$basePath/register'),
      headers: {'Content-type': 'application/json'},
      body:
          jsonEncode({'name': fullName, 'email': email, 'password': password}),
    );

    switch (response.statusCode) {
      case 201:
        return;
      case 409:
        throw EmailAlreadyExist();
      default:
        throw Exception(
          'Can\'t create a new account for the moment',
        );
    }
  }

  Future<void> logout() async {
    try {
      await httpClient.post(Uri.parse('$baseUrl$basePath/logout'));
    } on Unauthenticated {
      // already logged out, pass
    } finally {
      await tokenRepository.clearTokens();
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await tokenRepository.getAccessToken();
    return accessToken != null;
  }
}
