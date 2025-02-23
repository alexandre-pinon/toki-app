import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/app.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/hive/types/pending_task.dart';
import 'package:toki_app/hive/types/shopping_list_item.dart';
import 'package:toki_app/hive/types/unit_type.dart';
import 'package:toki_app/hive/types/weekday.dart';
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
    await initHive();
    initApp();
  }, (error, stackTrace) {
    if (error is Unauthenticated) {
      final context = scaffoldMessengerKey.currentContext;
      if (context != null) {
        context.read<AuthProvider>().logout();
        showGlobalSnackBar('Your session has expired, please login again');
      }
      return;
    }

    log('Unexpected error', error: error, stackTrace: stackTrace);

    final isNetworkError = error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused');

    if (isNetworkError) {
      showGlobalSnackBar(
        'Unable to connect to server, please check your connection',
        isError: false,
      );
    } else {
      showGlobalSnackBar(error.toString());
    }
  });
}

Future<void> loadEnv() async {
  if (kDebugMode) {
    await dotenv.load();
  } else {
    await dotenv.load(fileName: '.env.production');
  }
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UnitTypeAdapter());
  Hive.registerAdapter(WeekdayAdapter());
  Hive.registerAdapter(TaskTypeAdapter());
  Hive.registerAdapter(ShoppingListItemAdapter());
  Hive.registerAdapter(PendingTaskAdapter());
}

void initApp() {
  final tokenRepository = TokenRepository();
  final apiClient = ApiClient(
    baseUrl: dotenv.env['TOKI_API_URL']!,
    tokenRepository: tokenRepository,
  );

  final authService = AuthService(
    baseUrl: dotenv.env['TOKI_API_URL']!,
    tokenRepository: tokenRepository,
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

String? _lastMessage;
Timer? _debounceTimer;

void showGlobalSnackBar(String message, {bool isError = true}) {
  if (message == _lastMessage && _debounceTimer?.isActive == true) {
    return;
  }

  _lastMessage = message;
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    _lastMessage = null;
  });

  Future.microtask(() async {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError ? TextStyle(color: Colors.red.shade900) : null,
        ),
        backgroundColor: isError ? Colors.red.shade100 : null,
        duration: const Duration(seconds: 3),
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
