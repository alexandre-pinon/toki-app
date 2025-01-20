import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/screens/home_sceen.dart';
import 'package:toki_app/screens/login_screen.dart';

class TokiApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const TokiApp({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Toki',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff5ED19E)),
        useMaterial3: true,
      ),
      home: AppNavigator(),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (AuthProvider p) => p.isAuthenticated,
    );

    return isAuthenticated ? HomeScreen() : LoginScreen();
  }
}
