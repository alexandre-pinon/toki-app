import 'package:flutter/material.dart';
import 'package:toki_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  AuthProvider({required this.authService});

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    await authService.login(email, password);
    await notifyAuth();
  }

  Future<void> logout() async {
    await authService.logout();
    await notifyAuth();
  }

  Future<void> notifyAuth() async {
    _isAuthenticated = await authService.isAuthenticated();
    notifyListeners();
  }
}
