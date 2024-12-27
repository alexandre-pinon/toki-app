import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/recipe_edit_screen.dart';
import 'package:toki_app/types/meal_type.dart';
import 'package:toki_app/types/unit_type.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:toki_app/widgets/servings_input.dart';

class MealScreen extends StatefulWidget {
  final WeeklyPlannedMeal weeklyMeal;

  const MealScreen(this.weeklyMeal, {super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _initializeData();
    });
  }

  void _initializeData() async {
    final mealProvider = context.read<MealProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await mealProvider.initData(
        widget.weeklyMeal.id,
        widget.weeklyMeal.recipeId,
      );
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(mealProvider.recipe?.title ?? widget.weeklyMeal.title),
          actions: [
            if (mealProvider.recipeDetails != null)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeEditScreen(mealProvider.recipeDetails!),
                    ),
                  );
                },
                icon: Icon(Icons.edit),
              )
          ]),
      body: Builder(
        builder: (context) {
          if (!mealProvider.isInitialized || mealProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  mealProvider.recipe?.imageUrl ??
                      widget.weeklyMeal.imageUrl ??
                      'https://placehold.co/400x200.png',
                ),
              ),
              SizedBox(height: 16),
              RecipeHeader(
                meal: mealProvider.meal!,
                recipe: mealProvider.recipe!,
                recipeDetails: mealProvider.recipeDetails!,
              ),
              SizedBox(height: 16),
              RecipeIngredients(
                ingredients: mealProvider.ingredients,
                quantityRatio:
                    mealProvider.meal!.servings / mealProvider.recipe!.servings,
              ),
              SizedBox(height: 16),
              RecipeInstructions(mealProvider.instructions),
            ],
          );
        },
      ),
    );
  }
}

class RecipeHeader extends StatefulWidget {
  final PlannedMeal meal;
  final Recipe recipe;
  final RecipeDetails recipeDetails;

  const RecipeHeader({
    super.key,
    required this.meal,
    required this.recipe,
    required this.recipeDetails,
  });

  @override
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  late final ValueNotifier<MealType> _mealTypeController;
  late final ValueNotifier<int> _servingsController;
  late DateTime _mealDate;

  @override
  void initState() {
    super.initState();
    _mealTypeController = ValueNotifier(widget.meal.mealType);
    _servingsController = ValueNotifier(widget.meal.servings);
    _mealDate = widget.meal.mealDate;

    _mealTypeController.addListener(_saveData);
    _servingsController.addListener(_saveData);
  }

  @override
  void dispose() {
    _mealTypeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: widget.meal.mealDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 6)),
    );

    if (pickedDate != null) {
      setState(() {
        _mealDate = DateTime.utc(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
      });
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    final updatedMeal = widget.meal.copyWith(
      mealType: _mealTypeController.value,
      servings: _servingsController.value,
      mealDate: _mealDate,
    );

    final mealProvider = context.read<MealProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await mealProvider.updateMeal(updatedMeal);
      await weeklyMealsProvider.fetchMeals();
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe(prepTime: prepTime, cookTime: cookTime) = widget.recipe;
    final totalTime = (prepTime ?? 0) + (cookTime ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.recipe.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              OutlinedButton(
                style: ButtonStyle(visualDensity: VisualDensity.compact),
                onPressed: _pickDate,
                child: Text(
                  Weekday.fromDatetimeWeekday(widget.meal.mealDate.weekday)
                      .displayName,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: 100,
          child: ValueListenableBuilder(
            valueListenable: _mealTypeController,
            builder: (context, value, child) => DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  isDense: true,
                ),
                alignment: Alignment.center,
                icon: SizedBox.shrink(),
                value: value,
                items: MealType.values
                    .map(
                      (mealType) => DropdownMenuItem(
                        alignment: Alignment.center,
                        value: mealType,
                        child: Text(mealType.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _mealTypeController.value = newValue;
                  }
                }),
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
          title: ServingsInput(notifier: _servingsController),
        ),
      ],
    );
  }
}

class RecipeIngredients extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double quantityRatio;

  const RecipeIngredients({
    super.key,
    required this.ingredients,
    required this.quantityRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final quantity = ingredients[index].quantity != null
                ? ingredients[index].quantity! * quantityRatio
                : null;

            return RecipeIngredient(
              name: ingredients[index].name,
              unit: ingredients[index].unit,
              quantity: quantity,
            );
          },
        ),
      ],
    );
  }
}

class RecipeIngredient extends StatelessWidget {
  final String name;
  final UnitType? unit;
  final double? quantity;

  const RecipeIngredient({
    super.key,
    required this.name,
    this.unit,
    this.quantity,
  });

  String formatName(String name, UnitType? unit, double? quantity) {
    if (quantity != null && quantity > 1 && unit == null) {
      return '${name}s';
    }

    return name;
  }

  String formatUnit(String? unit) {
    return unit != null ? '$unit ' : '';
  }

  String formatQuantity(double? quantity) {
    if (quantity == null) return '';

    return quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final formattedName = formatName(name, unit, quantity);
    final formattedUnit = formatUnit(unit?.displayName);
    final formattedQuantity = formatQuantity(quantity);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text('• $formattedQuantity $formattedUnit$formattedName'),
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text('${instruction.stepNumber}. ${instruction.instruction}'),
    );
  }
}
