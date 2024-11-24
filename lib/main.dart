import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/app.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/repositories/token_repository.dart';
import 'package:toki_app/services/auth_service.dart';

//TODO: define as env variable
const TOKI_API_URL = 'http://192.168.1.17:3000';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  // catch all sync errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    showGlobalSnackBar('Unexpected error, please try again later');
  };

  // catch all async errors
  runZonedGuarded(initApp, (error, stackTrace) {
    log('Unexpected error', error: error, stackTrace: stackTrace);
    showGlobalSnackBar('Unexpected error, please try again later');
  });
}

void initApp() {
  final tokenRepository = TokenRepository();
  final authService = AuthService(
      baseUrl: '$TOKI_API_URL/auth', tokenRepository: tokenRepository);
  final app = ChangeNotifierProvider(
    create: (context) => AuthProvider(authService: authService),
    child: TokiApp(scaffoldMessengerKey: scaffoldMessengerKey),
  );

  runApp(app);
}

void showGlobalSnackBar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.red.shade900,
        ),
      ),
      backgroundColor: Colors.red.shade100,
      duration: const Duration(seconds: 3),
    ),
  );
}
