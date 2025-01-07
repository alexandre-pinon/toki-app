import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/shopping_list_item.dart';
import 'package:toki_app/repositories/token_repository.dart';

class ShoppingListItemService {
  final String baseUrl;
  final TokenRepository tokenRepository;

  ShoppingListItemService({
    required this.baseUrl,
    required this.tokenRepository,
  });

  Future<List<ShoppingListItem>> fetchItems() async {
    final accessToken = await tokenRepository.getAccessToken();
    if (accessToken == null) {
      return throw Unauthenticated();
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    switch (response.statusCode) {
      case 200:
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map(ShoppingListItem.fromJson).toList();
      case 401:
        throw Unauthenticated();
      default:
        throw Exception('Fetch shopping list items failed');
    }
  }
}
