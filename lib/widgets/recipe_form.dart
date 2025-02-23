import 'package:flutter/material.dart';
import 'package:toki_app/controllers/ingredient_controller.dart';
import 'package:toki_app/controllers/recipe_controller.dart';
import 'package:toki_app/hive/types/unit_type.dart';
import 'package:toki_app/widgets/servings_input.dart';

class RecipeForm extends StatefulWidget {
  final RecipeController recipeController;
  final List<IngredientController> ingredientControllers;
  final List<TextEditingController> instructionControllers;

  const RecipeForm({
    super.key,
    required this.recipeController,
    required this.ingredientControllers,
    required this.instructionControllers,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  void _addIngredient() {
    setState(() {
      widget.ingredientControllers.add(IngredientController.empty());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      widget.ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      widget.instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      widget.instructionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    widget.recipeController.dispose();

    for (final controller in widget.ingredientControllers) {
      controller.dispose();
    }
    for (final controller in widget.instructionControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
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
            titleController: widget.recipeController.titleController,
            prepTimeController: widget.recipeController.prepTimeController,
            cookTimeController: widget.recipeController.cookTimeController,
            servingsController: widget.recipeController.servingsController,
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
            ingredientControllers: widget.ingredientControllers,
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
            instructionControllers: widget.instructionControllers,
            addInstruction: _addInstruction,
            removeInstruction: _removeInstruction,
          ),
        ],
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
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
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
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
