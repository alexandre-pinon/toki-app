import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:toki_app/repositories/token_repository.dart';

class ApiClient {
  final String baseUrl;
  final TokenRepository tokenRepository;
  late final http.Client _client;

  ApiClient({required this.baseUrl, required this.tokenRepository}) {
    _client = RetryClient(
      _TokenAwareClient(tokenRepository),
      retries: 1,
      when: (response) => response.statusCode == 401,
      onRetry: (request, response, retryCount) async {
        await tokenRepository.refreshToken(_client, baseUrl);
      },
    );
  }

  Future<http.Response> get(String endpoint) async {
    final request = http.Request('GET', Uri.parse('$baseUrl$endpoint'));

    return await http.Response.fromStream(await _client.send(request));
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request('POST', Uri.parse('$baseUrl$endpoint'));

    if (body != null) {
      request.headers['Content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return await http.Response.fromStream(await _client.send(request));
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request('PUT', Uri.parse('$baseUrl$endpoint'));

    if (body != null) {
      request.headers['Content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return await http.Response.fromStream(await _client.send(request));
  }

  Future<http.Response> delete(String endpoint) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));

    return await http.Response.fromStream(await _client.send(request));
  }
}

class _TokenAwareClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final TokenRepository _tokenRepository;

  _TokenAwareClient(this._tokenRepository);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final accessToken = await _tokenRepository.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    return _inner.send(request);
  }
}
