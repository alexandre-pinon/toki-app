import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/widgets/servings_input.dart';

class AddMealStep4Screen extends StatelessWidget {
  const AddMealStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final servingsController = ValueNotifier(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add meal'),
        actions: [
          IconButton(
            onPressed: () {
              context
                  .read<MealCreationProvider>()
                  .setServings(servingsController.value);

              context.read<MealCreationProvider>().printData();
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    'For how many servings?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: ServingsInput(notifier: servingsController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
