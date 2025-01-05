import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/providers/recipes_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_2_screen.dart';
import 'package:toki_app/screens/recipe_add_screen.dart';
import 'package:toki_app/services/recipe_service.dart';

class AddMealStep1Screen extends StatefulWidget {
  const AddMealStep1Screen({super.key});

  @override
  State<AddMealStep1Screen> createState() => _AddMealStep1ScreenState();
}

class _AddMealStep1ScreenState extends State<AddMealStep1Screen> {
  Future<void> fetchRecipes() async {
    final recipesProvider = context.read<RecipesProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await recipesProvider.fetchRecipes();
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add meal'),
      ),
      body: Builder(builder: (context) {
        final recipesProvider = context.watch<RecipesProvider>();

        if (recipesProvider.loading) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Select a recipe:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: recipesProvider.recipes.length,
              itemBuilder: (context, index) => RecipeCard(
                recipe: recipesProvider.recipes[index],
              ),
            ),
            Center(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeAddScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Add recipe'),
              ),
            )
          ],
        );
      }),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  Future<void> _deleteRecipe(BuildContext context, String recipeId) async {
    final recipeService = context.read<RecipeService>();
    final recipesProvider = context.read<RecipesProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await recipeService.deleteRecipe(recipeId);
      await recipesProvider.fetchRecipes();
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
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
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.red,
        ),
      ),
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              recipe.imageUrl ?? 'https://placehold.co/64.png',
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
            context.read<MealCreationProvider>().setRecipeId(recipe.id);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMealStep2Screen()),
            );
          },
        ),
      ),
    );
  }
}
