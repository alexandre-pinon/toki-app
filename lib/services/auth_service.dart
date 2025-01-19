import 'dart:convert';

import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/repositories/token_repository.dart';
import 'package:toki_app/services/api_client.dart';

class AuthService {
  static const basePath = '/auth';
  final TokenRepository tokenRepository;
  final ApiClient apiClient;

  AuthService({required this.tokenRepository, required this.apiClient});

  Future<void> login(String email, String password) async {
    final response = await apiClient.post(
      '$basePath/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Can\'t log you in for the moment');
    }

    final responseBody = jsonDecode(response.body);
    await tokenRepository.saveTokens(
      responseBody['access_token'],
      responseBody['refresh_token'],
    );
  }

  Future<void> register(String fullName, String email, String password) async {
    final response = await apiClient.post(
      '$basePath/register',
      body: {'name': fullName, 'email': email, 'password': password},
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
      await apiClient.post('$basePath/logout');
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
