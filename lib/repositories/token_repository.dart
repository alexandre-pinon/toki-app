import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toki_app/errors/auth_error.dart';

class TokenRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  Future<void>? _refreshRequest;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> refreshToken(http.Client client, String baseUrl) async {
    // If there is an ongoing request, await it
    if (_refreshRequest != null) {
      return await _refreshRequest;
    }

    // Else start the refresh token process
    _refreshRequest = _refreshToken(client, baseUrl);

    try {
      await _refreshRequest;
    } finally {
      _refreshRequest = null;
    }
  }

  Future<void> _refreshToken(http.Client client, String baseUrl) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw Unauthenticated();
    }

    final responseBody = jsonDecode(response.body);
    await saveTokens(
      responseBody['access_token'],
      responseBody['refresh_token'],
    );
  }
}
