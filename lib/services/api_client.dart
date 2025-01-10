import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/repositories/token_repository.dart';

class ApiClient {
  final String baseUrl;
  final TokenRepository tokenRepository;
  final http.Client _client = http.Client();

  ApiClient({required this.baseUrl, required this.tokenRepository});

  Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final request = http.Request('GET', Uri.parse('$baseUrl$endpoint'));

    return await _sendRequest(request, authenticated);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final request = http.Request('POST', Uri.parse('$baseUrl$endpoint'));

    if (body != null) {
      request.headers['Content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return await _sendRequest(request, authenticated);
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final request = http.Request('PUT', Uri.parse('$baseUrl$endpoint'));

    if (body != null) {
      request.headers['Content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return await _sendRequest(request, authenticated);
  }

  Future<http.Response> delete(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));

    return await _sendRequest(request, authenticated);
  }

  Future<http.Response> _sendRequest(
    http.Request request,
    bool authenticated,
  ) async {
    if (!authenticated) {
      return await _tryRequest(request);
    }

    final response = await _tryAuthenticatedRequest(request);

    if (response.statusCode == 401) {
      await _refreshToken();
      return await _tryAuthenticatedRequest(request);
    }

    return response;
  }

  Future<http.Response> _tryAuthenticatedRequest(http.Request request) async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      throw Unauthenticated();
    }

    request.headers['Authorization'] = 'Bearer $accessToken';
    return await _tryRequest(request);
  }

  Future<http.Response> _tryRequest(http.Request request) async {
    return await http.Response.fromStream(await _client.send(request));
  }

  Future<void> _refreshToken() async {
    final refreshToken = await tokenRepository.getRefreshToken();
    if (refreshToken == null) {
      throw Unauthenticated();
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw Unauthenticated();
    }

    final responseBody = jsonDecode(response.body);
    await tokenRepository.saveTokens(
      responseBody['access_token'],
      responseBody['refresh_token'],
    );
  }
}
