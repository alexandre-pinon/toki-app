import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/recipes_provider.dart';
import 'package:toki_app/screens/recipe_add_screen.dart';
import 'package:toki_app/widgets/recipe_card.dart';

class RecipeList extends StatefulWidget {
  final Function({
    required BuildContext context,
    required String recipeId,
  }) onTapCard;

  const RecipeList({super.key, required this.onTapCard});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchRecipes);
  }

  Future<void> _fetchRecipes() async {
    final recipesProvider = context.read<RecipesProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await recipesProvider.fetchRecipes();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final recipesProvider = context.watch<RecipesProvider>();

        if (recipesProvider.loading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select a recipe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipesProvider.recipes.length,
              itemBuilder: (context, index) => RecipeCard(
                recipe: recipesProvider.recipes[index],
                onTap: widget.onTapCard,
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
            ),
            SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
