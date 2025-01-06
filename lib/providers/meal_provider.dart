import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/loading_change_notifier.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/services/recipe_service.dart';

class MealProvider extends LoadingChangeNotifier {
  final PlannedMealService mealService;
  final RecipeService recipeService;

  MealProvider({required this.mealService, required this.recipeService});

  PlannedMeal? _meal;
  PlannedMeal? get meal => _meal;

  RecipeDetails? _recipeDetails;
  RecipeDetails? get recipeDetails => _recipeDetails;

  Recipe? get recipe => _recipeDetails?.recipe;
  List<Ingredient> get ingredients =>
      _recipeDetails != null ? _recipeDetails!.ingredients : [];
  List<Instruction> get instructions =>
      _recipeDetails != null ? _recipeDetails!.instructions : [];

  bool get isInitialized {
    return [_meal, _recipeDetails].every((data) => data != null);
  }

  void resetData() {
    _meal = null;
    _recipeDetails = null;
    notifyListeners();
  }

  Future<void> initData(String mealId, String recipeId) async {
    await withLoading(() async {
      await Future.wait([_initMeal(mealId), _initRecipeDetails(recipeId)]);
    });
  }

  Future<void> _initMeal(String mealId) async {
    _meal = await mealService.fetchPlannedMeal(mealId);
  }

  Future<void> _initRecipeDetails(String recipeId) async {
    _recipeDetails = await recipeService.fetchRecipeDetails(recipeId);
  }

  Future<void> fetchRecipeDetails(String recipeId) async {
    await withLoading(
      () async {
        await _initRecipeDetails(recipeId);
      },
    );
  }

  Future<void> updateMeal(PlannedMeal meal) async {
    await withLoading(() async {
      _meal = await mealService.updatePlannedMeal(meal);
    });
  }

  Future<void> updateRecipe(RecipeDetails recipeDetails) async {
    await withLoading(() async {
      _recipeDetails = await recipeService.updateRecipe(recipeDetails);
    });
  }
}
