import 'package:flutter/material.dart';
import 'package:toki_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider({required this.authService}) {
    _checkAuth();
  }

  Future<void> login(String email, String password) async {
    await authService.login(email, password);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register(String fullName, String email, String password) async {
    await authService.register(fullName, email, password);
    await login(email, password);
  }

  Future<void> logout() async {
    await authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await authService.isAuthenticated();
    notifyListeners();
  }
}
