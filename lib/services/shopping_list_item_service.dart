import 'dart:convert';

import 'package:toki_app/hive/types/shopping_list_item.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/services/api_client.dart';

class ShoppingListItemService {
  static const basePath = '/shopping-list-item';
  final ApiClient apiClient;

  ShoppingListItemService({required this.apiClient});

  Future<List<ShoppingListItem>> fetchItems() async {
    final response = await apiClient.get(basePath);

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve shopping list items for the moment');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map(ShoppingListItem.fromJson).toList();
  }

  Future<void> createItem(Ingredient input) async {
    final response = await apiClient.post(
      basePath,
      body: input.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception('Cannot create a new shopping list item for the moment');
    }
  }

  Future<void> updateItemIngredient(String itemId, Ingredient input) async {
    final response = await apiClient.put(
      '$basePath/$itemId',
      body: input.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot update this shopping list item for the moment');
    }
  }

  Future<void> checkItem(ShoppingListItem item) async {
    final responses = await Future.wait(
      item.ids.map((id) => apiClient.put('$basePath/$id/check')),
    );

    if (responses.any((response) => response.statusCode != 204)) {
      throw Exception('Cannot check this shopping list item for the moment');
    }
  }

  Future<void> uncheckItem(ShoppingListItem item) async {
    final responses = await Future.wait(
      item.ids.map((id) => apiClient.put('$basePath/$id/uncheck')),
    );

    if (responses.any((response) => response.statusCode != 204)) {
      throw Exception('Cannot uncheck this shopping list item for the moment');
    }
  }

  Future<void> deleteItem(String itemId) async {
    final response = await apiClient.delete('$basePath/$itemId');

    if (response.statusCode != 204) {
      throw Exception('Cannot delete this shopping list item for the moment');
    }
  }
}
