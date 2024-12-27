import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/instruction.dart';
import 'package:toki_app/models/recipe_details.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/types/unit_type.dart';
import 'package:toki_app/widgets/servings_input.dart';

class RecipeEditScreen extends StatefulWidget {
  final RecipeDetails recipeDetails;

  const RecipeEditScreen(this.recipeDetails, {super.key});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final ValueNotifier<int> _servingsController;
  late final List<IngredientController> _ingredientControllers;
  late final List<TextEditingController> _instructionControllers;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipeDetails.recipe;
    _titleController = TextEditingController(text: recipe.title);
    _prepTimeController = TextEditingController(
      text: recipe.prepTime?.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: recipe.cookTime?.toString() ?? '',
    );
    _servingsController = ValueNotifier(recipe.servings);
    _ingredientControllers = widget.recipeDetails.ingredients
        .map(IngredientController.fromIngredient)
        .toList();
    _instructionControllers = widget.recipeDetails.instructions
        .map(
          (instruction) => TextEditingController(text: instruction.instruction),
        )
        .toList();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(IngredientController.empty());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _saveData() async {
    final updatedRecipe = widget.recipeDetails.recipe.copyWith(
      title: _titleController.text,
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      servings: _servingsController.value,
    );
    final updatedIngredients = _ingredientControllers
        .map(
          (controller) => controller.value,
        )
        .toList();
    final updatedInstructions = _instructionControllers
        .mapIndexed(
          (index, controller) => Instruction(index + 1, controller.text),
        )
        .toList();
    final updatedRecipeDetails =
        RecipeDetails(updatedRecipe, updatedIngredients, updatedInstructions);

    final mealProvider = context.read<MealProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await mealProvider.updateRecipe(updatedRecipeDetails);
      await weeklyMealsProvider.fetchMeals(); // refresh home page data
      navigator.pop();
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();

    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _instructionControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            'Edit ${widget.recipeDetails.recipe.title.toLowerCase()} recipe'),
        actions: [
          IconButton(
            onPressed: _saveData,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recipe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 16),
            RecipeInput(
              titleController: _titleController,
              prepTimeController: _prepTimeController,
              cookTimeController: _cookTimeController,
              servingsController: _servingsController,
            ),
            SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IngredientsInput(
              ingredientControllers: _ingredientControllers,
              addIngredient: _addIngredient,
              removeIngredient: _removeIngredient,
            ),
            SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            InstructionsInput(
              instructionControllers: _instructionControllers,
              addInstruction: _addInstruction,
              removeInstruction: _removeInstruction,
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeInput extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final ValueNotifier<int> servingsController;

  const RecipeInput({
    super.key,
    required this.titleController,
    required this.prepTimeController,
    required this.cookTimeController,
    required this.servingsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Recipe title'),
          ),
        ),
        SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: prepTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.schedule),
                    labelText: 'Prep time (min)',
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: cookTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.schedule),
                    labelText: 'Cook time (min)',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ServingsInput(notifier: servingsController),
        )
      ],
    );
  }
}

class IngredientsInput extends StatelessWidget {
  final List<IngredientController> ingredientControllers;
  final VoidCallback addIngredient;
  final void Function(int index) removeIngredient;

  const IngredientsInput({
    super.key,
    required this.ingredientControllers,
    required this.addIngredient,
    required this.removeIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ingredientControllers.length,
          itemBuilder: (context, index) => IngredientInput(
            controller: ingredientControllers[index],
            onDelete: () => removeIngredient(index),
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add ingredient'),
          onPressed: addIngredient,
        ),
      ],
    );
  }
}

class IngredientInput extends StatelessWidget {
  final IngredientController controller;
  final VoidCallback onDelete;

  const IngredientInput({
    super.key,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(width: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: controller.unitController,
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
                      onChanged: (newValue) {
                        controller.unitController.value = newValue;
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InstructionsInput extends StatelessWidget {
  final List<TextEditingController> instructionControllers;
  final VoidCallback addInstruction;
  final void Function(int index) removeInstruction;

  const InstructionsInput({
    super.key,
    required this.instructionControllers,
    required this.addInstruction,
    required this.removeInstruction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: instructionControllers.length,
          itemBuilder: (context, index) => InstructionInput(
            controller: instructionControllers[index],
            onDelete: () => removeInstruction(index),
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add instruction'),
          onPressed: addInstruction,
        ),
      ],
    );
  }
}

class InstructionInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  const InstructionInput({
    super.key,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Instruction',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
