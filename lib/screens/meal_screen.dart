import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/ingredient.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/models/recipe.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/types/meal_type.dart';
import 'package:toki_app/types/unit_type.dart';

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
      ),
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

  const RecipeHeader({super.key, required this.meal, required this.recipe});

  @override
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  final _formKey = GlobalKey<FormState>();
  late final ValueNotifier<MealType> _mealTypeController;
  late final TextEditingController _mealServingsController;
  late final TextEditingController _titleController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _recipeServingsController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _mealTypeController = ValueNotifier(widget.meal.mealType);
    _mealServingsController = TextEditingController(
      text: widget.meal.servings.toString(),
    );
    _titleController = TextEditingController(text: widget.recipe.title);
    _prepTimeController = TextEditingController(
      text: widget.recipe.prepTime?.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: widget.recipe.cookTime?.toString() ?? '',
    );
    _recipeServingsController = TextEditingController(
      text: widget.recipe.servings.toString(),
    );
  }

  @override
  void dispose() {
    _mealTypeController.dispose();
    _mealServingsController.dispose();
    _titleController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _recipeServingsController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isEditing = false;
    });

    final meal = PlannedMeal(
      widget.meal.id,
      widget.meal.userId,
      widget.meal.recipeId,
      widget.meal.mealDate,
      _mealTypeController.value,
      int.parse(_mealServingsController.text),
    );
    final recipe = Recipe(
      widget.recipe.id,
      widget.recipe.userId,
      _titleController.text,
      int.parse(_prepTimeController.text),
      int.parse(_cookTimeController.text),
      int.parse(_recipeServingsController.text),
      widget.recipe.sourceUrl,
      widget.recipe.imageUrl,
      widget.recipe.cuisineType,
      widget.recipe.rating,
    );
    final authProvider = context.read<AuthProvider>();
    final mealProvider = context.read<MealProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();

    try {
      //! update recipe servings first to update shopping list items with correct quantities
      await mealProvider.updateRecipe(recipe);
      await mealProvider.updateMeal(meal);
      await weeklyMealsProvider.fetchMeals(); // update parent UI
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe(prepTime: prepTime, cookTime: cookTime) = widget.recipe;
    final totalTime = (prepTime ?? 0) + (cookTime ?? 0);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isEditing) ...[
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
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                visualDensity: VisualDensity(vertical: -4),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Text(
                  widget.meal.mealType.displayName,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
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
              title: Text('Servings: ${widget.meal.servings}'),
              subtitle: Text('Recipe servings: ${widget.recipe.servings}'),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Recipe title'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder(
                valueListenable: _mealTypeController,
                builder: (context, value, child) => DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Select a meal type',
                    ),
                    value: value,
                    items: MealType.values
                        .map(
                          (mealType) => DropdownMenuItem(
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
              title: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _prepTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Prep time (min)'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Cook time (min)'),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _mealServingsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Meal servings'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: TextFormField(
                      controller: _recipeServingsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Recipe servings'),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: saveChanges, child: Text('Save')),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: Text('Cancel'),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class RecipeIngredients extends StatefulWidget {
  final List<Ingredient> ingredients;
  final double quantityRatio;

  const RecipeIngredients({
    super.key,
    required this.ingredients,
    required this.quantityRatio,
  });

  @override
  State<RecipeIngredients> createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  final _formKey = GlobalKey<FormState>();
  late final List<Ingredient> ingredients;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    ingredients = widget.ingredients;
  }

  void addIngredient() {
    setState(() {
      // removed ids ?
      ingredients.add(Ingredient(id, recipeId, name, quantity, unit));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: Icon(Icons.edit),
              )
            ],
          ),
        ),
        SizedBox(height: 8),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.ingredients
                .map((ingredient) => _isEditing
                    ? RecipeIngredient(
                        name: ingredient.name,
                        unit: ingredient.unit,
                        quantity: ingredient.quantity != null
                            ? ingredient.quantity! * widget.quantityRatio
                            : null,
                      )
                    : RecipeIngredientInput(
                        name: ingredient.name,
                        unit: ingredient.unit,
                        quantity: ingredient.quantity != null
                            ? ingredient.quantity! * widget.quantityRatio
                            : null,
                      ))
                .toList(),
          ),
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

class RecipeIngredientInput extends StatefulWidget {
  final String name;
  final UnitType? unit;
  final double? quantity;

  const RecipeIngredientInput({
    super.key,
    required this.name,
    this.unit,
    this.quantity,
  });

  @override
  State<RecipeIngredientInput> createState() => _RecipeIngredientInputState();
}

class _RecipeIngredientInputState extends State<RecipeIngredientInput> {
  late final TextEditingController _nameController;
  late final ValueNotifier<UnitType?> _unitController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _unitController = ValueNotifier(widget.unit);
    _quantityController = TextEditingController(
      text: widget.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [],
      ),
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
