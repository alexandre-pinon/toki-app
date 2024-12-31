import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_2_screen.dart';
import 'package:toki_app/services/recipe_service.dart';

class AddMealStep1Screen extends StatelessWidget {
  const AddMealStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add meal'),
      ),
      body: FutureBuilder(
          future: context.read<RecipeService>().fetchRecipes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final recipes = snapshot.data!;

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
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => RecipeCard(
                    recipe: recipes[index],
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

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  'Prep: ${recipe.prepTime != null ? "${recipe.prepTime} min" : "-"}'),
              VerticalDivider(),
              Text(
                  'Cook: ${recipe.cookTime != null ? "${recipe.cookTime} min" : "-"}'),
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
    );
  }
}
