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
                recipeId: mealProvider.recipe!.id,
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
  final String recipeId;
  final List<Ingredient> ingredients;
  final double quantityRatio;

  const RecipeIngredients({
    super.key,
    required this.recipeId,
    required this.ingredients,
    required this.quantityRatio,
  });

  @override
  State<RecipeIngredients> createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  final _formKey = GlobalKey<FormState>();
  late final List<Ingredient> formIngredients;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    formIngredients = [];
    formIngredients.addAll(widget.ingredients);
  }

  void addIngredient() {
    setState(() {
      formIngredients.add(Ingredient('', null, null));
    });
  }

  void removeIngredient(int index) {
    setState(() {
      formIngredients.removeAt(index);
    });
  }

  void updateIngredient(int index, Ingredient updatedIngredient) {
    setState(() {
      formIngredients[index] = updatedIngredient;
    });
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isEditing = false;
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
                  style: Theme.of(context).textTheme.titleLarge,
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
            children: [
              _isEditing
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: formIngredients.length,
                      itemBuilder: (context, index) {
                        return RecipeIngredientInput(
                          ingredient: formIngredients[index],
                          quantityRatio: widget.quantityRatio,
                          onDelete: () => removeIngredient(index),
                          onUpdate: (ing) => updateIngredient(index, ing),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.ingredients.length,
                      itemBuilder: (context, index) {
                        final quantity =
                            widget.ingredients[index].quantity != null
                                ? widget.ingredients[index].quantity! *
                                    widget.quantityRatio
                                : null;

                        return RecipeIngredient(
                          name: widget.ingredients[index].name,
                          unit: widget.ingredients[index].unit,
                          quantity: quantity,
                        );
                      },
                    ),
              if (_isEditing) ...[
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add ingredient'),
                  onPressed: addIngredient,
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

class RecipeIngredientInput extends StatelessWidget {
  final Ingredient ingredient;
  final double quantityRatio;
  final VoidCallback onDelete;
  final ValueChanged<Ingredient> onUpdate;

  const RecipeIngredientInput({
    super.key,
    required this.ingredient,
    required this.quantityRatio,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = ingredient.quantity != null
        ? ingredient.quantity! * quantityRatio
        : null;
    final nameController = TextEditingController(text: ingredient.name);
    final unitController = ValueNotifier<UnitType?>(ingredient.unit);
    final quantityController = TextEditingController(text: quantity.toString());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              onUpdate(
                Ingredient(value, ingredient.quantity, ingredient.unit),
              );
            },
          ),
          SizedBox(width: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    onUpdate(
                      Ingredient(
                        ingredient.name,
                        double.parse(value) * quantityRatio,
                        ingredient.unit,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: unitController,
                  builder: (context, value, child) {
                    final items = UnitType.values
                        .map(
                          (unitType) => DropdownMenuItem(
                            value: unitType,
                            child: Text(unitType.displayName),
                          ),
                        )
                        .toList();
                    items.add(
                      DropdownMenuItem(value: null, child: Text('(none)')),
                    );

                    return DropdownButtonFormField(
                      decoration: InputDecoration(labelText: 'Unit'),
                      value: value,
                      items: items,
                      onChanged: (value) {
                        onUpdate(
                          Ingredient(
                            ingredient.name,
                            ingredient.quantity,
                            value,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
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
