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
    withLoading(() async {
      await Future.wait([initMeal(mealId), initRecipeDetails(recipeId)]);
    });
  }

  Future<void> initMeal(String mealId) async {
    _meal = await mealService.fetchPlannedMeal(mealId);
  }

  Future<void> initRecipeDetails(String recipeId) async {
    _recipeDetails = await recipeService.fetchRecipeDetails(recipeId);
  }

  Future<void> updateMeal(PlannedMeal meal) async {
    withLoading(() async {
      _meal = await mealService.updatePlannedMeal(meal);
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    withLoading(() async {
      _recipeDetails = await recipeService.updateRecipe(recipe);
    });
  }
}
