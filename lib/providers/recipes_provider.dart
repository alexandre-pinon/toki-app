import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/providers/loading_change_notifier.dart';
import 'package:toki_app/services/recipe_service.dart';

class RecipesProvider extends LoadingChangeNotifier {
  final RecipeService recipeService;

  RecipesProvider({required this.recipeService});

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  Future<void> fetchRecipes() async {
    await withLoading(() async {
      _recipes = await recipeService.fetchRecipes();
    });
  }
}
