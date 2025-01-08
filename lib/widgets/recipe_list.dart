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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
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
            )
          ],
        );
      },
    );
  }
}
