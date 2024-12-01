import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/screens/login_screen.dart';
import 'package:toki_app/services/recipe_service.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/types/unit_type.dart';

class MealScreen extends StatelessWidget {
  final PlannedMeal meal;

  const MealScreen(this.meal, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(meal.title),
      ),
      body: FutureBuilder(
        future: context.read<RecipeService>().fetchRecipeDetails(meal.recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (snapshot.error is Unauthenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showGlobalSnackBar(snapshot.error.toString());
              });
            }

            return Center(child: CircularProgressIndicator());
          }

          final RecipeDetails(
            recipe: recipe,
            ingredients: ingredients,
            instructions: instructions
          ) = snapshot.data!;

          return ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  meal.imageUrl ?? 'https://placehold.co/400x200.png',
                ),
              ),
              SizedBox(height: 16),
              RecipeHeader(recipe),
              SizedBox(height: 16),
              RecipeIngredients(ingredients),
              SizedBox(height: 16),
              RecipeInstructions(instructions),
            ],
          );
        },
      ),
    );
  }
}

class RecipeHeader extends StatelessWidget {
  final Recipe recipe;

  const RecipeHeader(this.recipe, {super.key});

  @override
  Widget build(BuildContext context) {
    final Recipe(prepTime: prepTime, cookTime: cookTime) = recipe;
    final totalTime = (prepTime ?? 0) + (cookTime ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            recipe.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ListTile(
          leading: Icon(Icons.schedule),
          title: Text('Total: ${totalTime > 0 ? "$totalTime min" : "-"}'),
          subtitle: SizedBox(
            height: 16,
            child: Row(
              children: [
                Text('Prep: ${prepTime != null ? "$prepTime min" : "-"}'),
                VerticalDivider(),
                Text('Cook: ${cookTime != null ? "$cookTime min" : "-"}'),
              ],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.restaurant_menu),
          title: Text('Servings: ${recipe.servings}'),
        )
      ],
    );
  }
}

class RecipeIngredients extends StatelessWidget {
  final List<Ingredient> ingredients;

  const RecipeIngredients(this.ingredients, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients
              .map((ingredient) => RecipeIngredient(ingredient))
              .toList(),
        ),
      ],
    );
  }
}

class RecipeIngredient extends StatelessWidget {
  final Ingredient ingredient;

  const RecipeIngredient(this.ingredient, {super.key});

  String formatQuantity(double? quantity) {
    if (quantity == null) return '';

    return quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toString();
  }

  String formatUnit(String? unit) {
    return unit != null ? '$unit ' : '';
  }

  String formatName(Ingredient ingredient) {
    final Ingredient(quantity: quantity, unit: unit, name: name) = ingredient;

    if (quantity != null && quantity > 1 && unit == null) {
      return '${name}s';
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
    final quantity = formatQuantity(ingredient.quantity);
    final unit = formatUnit(ingredient.unit?.displayName);
    final name = formatName(ingredient);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text('• $quantity $unit$name'),
    );
  }
}

class RecipeInstructions extends StatelessWidget {
  final List<Instruction> instructions;

  const RecipeInstructions(this.instructions, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: instructions
              .map((instruction) => RecipeInstruction(instruction))
              .toList(),
        ),
      ],
    );
  }
}

class RecipeInstruction extends StatelessWidget {
  final Instruction instruction;

  const RecipeInstruction(this.instruction, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text('${instruction.stepNumber}. ${instruction.instruction}'),
    );
  }
}
