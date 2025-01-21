import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/recipes_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/services/recipe_service.dart';

class RecipeCard extends StatelessWidget {
  final Function({
    required BuildContext context,
    required String recipeId,
  }) onTap;
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  Future<void> _deleteRecipe(BuildContext context, String recipeId) async {
    final recipeService = context.read<RecipeService>();
    final recipesProvider = context.read<RecipesProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await recipeService.deleteRecipe(recipeId);
      await Future.wait([
        recipesProvider.fetchRecipes(),
        weeklyMealsProvider.fetchMeals(),
      ]);
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(recipe.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showConfirmationDialog(
        context: context,
        title: 'Remove ${recipe.title.toLowerCase()} recipe?',
      ),
      onDismissed: (direction) {
        _deleteRecipe(context, recipe.id);
      },
      dismissThresholds: {DismissDirection.endToStart: 0.2},
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.error,
        ),
        alignment: AlignmentDirectional.centerEnd,
        child: Icon(Icons.delete),
      ),
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: recipe.imageUrl != null
                ? Image.network(recipe.imageUrl!)
                : Image.asset(
                    'assets/images/breakfast.png',
                    width: 64,
                    height: 64,
                  ),
          ),
          title: Text(recipe.title),
          subtitle: SizedBox(
            height: 20,
            child: Row(
              children: [
                Text(
                  'Prep: ${recipe.prepTime != null ? "${recipe.prepTime} min" : "-"}',
                ),
                VerticalDivider(),
                Text(
                  'Cook: ${recipe.cookTime != null ? "${recipe.cookTime} min" : "-"}',
                ),
              ],
            ),
          ),
          onTap: () {
            onTap(context: context, recipeId: recipe.id);
          },
        ),
      ),
    );
  }
}
