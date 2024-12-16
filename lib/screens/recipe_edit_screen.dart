import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/models/recipe_details.dart';
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
  late final List<IngredientController> _ingredientsController;

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
    _ingredientsController = widget.recipeDetails.ingredients
        .map(IngredientController.fromIngredient)
        .toList();
  }

  void _addIngredient() {
    setState(() {
      _ingredientsController.add(IngredientController.empty());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientsController.removeAt(index);
    });
  }

  Future<void> _saveData() async {
    final updatedRecipe = widget.recipeDetails.recipe.copyWith(
      title: _titleController.text,
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      servings: _servingsController.value,
    );
    final updatedIngredients = _ingredientsController
        .map(
          (controller) => controller.value,
        )
        .toList();

    // Simulate saving
    print('Saving: ${updatedRecipe.toJson()}');
    print(
      'Saving: ${updatedIngredients.map((ingredient) => ingredient.toJson())}',
    );

    // Call your save service or state management logic
    // await RecipeService.saveRecipe(updatedRecipe);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();

    for (final controller in _ingredientsController) {
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
          TextButton(
            onPressed: _saveData,
            child: Text('Save'),
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
            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RecipeIngredientsInput(
              ingredientsController: _ingredientsController,
              addIngredient: _addIngredient,
              removeIngredient: _removeIngredient,
            )
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

class RecipeIngredientsInput extends StatelessWidget {
  final List<IngredientController> ingredientsController;
  final VoidCallback addIngredient;
  final void Function(int index) removeIngredient;

  const RecipeIngredientsInput({
    super.key,
    required this.ingredientsController,
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
          itemCount: ingredientsController.length,
          itemBuilder: (context, index) => RecipeIngredientInput(
            controller: ingredientsController[index],
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

class RecipeIngredientInput extends StatelessWidget {
  final IngredientController controller;
  final VoidCallback onDelete;

  const RecipeIngredientInput({
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
