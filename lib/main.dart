import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/app.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/repositories/token_repository.dart';
import 'package:toki_app/services/auth_service.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/services/recipe_service.dart';

//TODO: define as env variable
const TOKI_API_HOST = '192.168.1.17';
const TOKI_API_URL = 'http://$TOKI_API_HOST:3000';

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
    baseUrl: '$TOKI_API_URL/auth',
    tokenRepository: tokenRepository,
  );
  final mealService = PlannedMealService(
    baseUrl: '$TOKI_API_URL/planned-meals',
    tokenRepository: tokenRepository,
  );
  final recipeService = RecipeService(
    baseUrl: '$TOKI_API_URL/recipes',
    tokenRepository: tokenRepository,
  );

  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AuthProvider(authService: authService),
      ),
      ChangeNotifierProvider(
        create: (context) => MealProvider(
          mealService: mealService,
          recipeService: recipeService,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => WeeklyMealsProvider(mealService: mealService),
      ),
      Provider(create: (context) => mealService),
    ],
    child: TokiApp(scaffoldMessengerKey: scaffoldMessengerKey),
  );

  runApp(app);
}

void showGlobalSnackBar(String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red.shade900),
        ),
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 5),
      ),
    );
  });
}
