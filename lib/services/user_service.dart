import 'dart:convert';

import 'package:toki_app/models/user.dart';
import 'package:toki_app/services/api_client.dart';

class UserService {
  static const basePath = '/users';
  final ApiClient apiClient;

  UserService({required this.apiClient});

  Future<User> getProfile() async {
    final response = await apiClient.get('$basePath/me');

    if (response.statusCode != 200) {
      throw Exception('Cannot retrieve your profile for the moment');
    }

    final json = jsonDecode(response.body);
    return User.fromJson(json);
  }

  Future<User> updateProfile(String name) async {
    final response = await apiClient.put(
      '$basePath/me',
      body: {'name': name},
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot update your profile for the moment');
    }

    final json = jsonDecode(response.body);
    return User.fromJson(json);
  }
}
