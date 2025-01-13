import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/app.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/recipes_provider.dart';
import 'package:toki_app/providers/shopping_list_provider.dart';
import 'package:toki_app/providers/user_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/repositories/token_repository.dart';
import 'package:toki_app/services/api_client.dart';
import 'package:toki_app/services/auth_service.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/services/recipe_service.dart';
import 'package:toki_app/services/shopping_list_item_service.dart';
import 'package:toki_app/services/user_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  // catch all sync errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    showGlobalSnackBar('Unexpected error, please try again later');
  };

  // catch all async errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await loadEnv();
    initApp();
  }, (error, stackTrace) {
    log('Unexpected error', error: error, stackTrace: stackTrace);
    showGlobalSnackBar('Unexpected error, please try again later');
  });
}

Future<void> loadEnv() async {
  if (kDebugMode) {
    await dotenv.load();
  } else {
    await dotenv.load(fileName: '.env.production');
  }
}

void initApp() {
  final tokenRepository = TokenRepository();
  final apiClient = ApiClient(
    baseUrl: dotenv.env['TOKI_API_URL']!,
    tokenRepository: tokenRepository,
  );

  final authService = AuthService(
    tokenRepository: tokenRepository,
    apiClient: apiClient,
  );
  final mealService = PlannedMealService(apiClient: apiClient);
  final recipeService = RecipeService(apiClient: apiClient);
  final shoppingListItemService = ShoppingListItemService(apiClient: apiClient);
  final userService = UserService(apiClient: apiClient);

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
      ChangeNotifierProvider(
        create: (context) => MealCreationProvider(
          mealService: mealService,
          recipeService: recipeService,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => RecipesProvider(recipeService: recipeService),
      ),
      ChangeNotifierProvider(
        create: (context) => ShoppingListProvider(
          shoppingListItemService: shoppingListItemService,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => UserProvider(userService: userService),
      ),
      Provider(create: (context) => mealService),
      Provider(create: (context) => recipeService),
    ],
    child: TokiApp(scaffoldMessengerKey: scaffoldMessengerKey),
  );

  runApp(app);
}

void showGlobalSnackBar(String message) {
  Future.microtask(() async {
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

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  String? content,
}) async {
  final deleteConfirmation = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: content != null ? Text(content) : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            'No',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('Yes'),
        ),
      ],
    ),
  );
  return deleteConfirmation ?? false;
}
