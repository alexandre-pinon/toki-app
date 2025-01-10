import 'package:flutter/material.dart';
import 'package:toki_app/models/user.dart';
import 'package:toki_app/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;

  UserProvider({required this.userService});

  User? _user;
  User? get user => _user;

  Future<void> getProfile() async {
    _user = await userService.getProfile();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _user = await userService.updateProfile(name);
    notifyListeners();
  }
}
