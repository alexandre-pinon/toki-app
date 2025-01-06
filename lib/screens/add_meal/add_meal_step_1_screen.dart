import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_2_screen.dart';
import 'package:toki_app/widgets/recipe_list.dart';

class AddMealStep1Screen extends StatelessWidget {
  const AddMealStep1Screen({super.key});

  void _setRecipeAndGoToNextStep({
    required BuildContext context,
    required String recipeId,
  }) {
    context.read<MealCreationProvider>().setRecipeId(recipeId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMealStep2Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add meal'),
      ),
      body: RecipeList(onTapCard: _setRecipeAndGoToNextStep),
    );
  }
}
