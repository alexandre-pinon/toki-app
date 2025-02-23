import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/home_sceen.dart';
import 'package:toki_app/widgets/servings_input.dart';

class AddMealStep4Screen extends StatelessWidget {
  const AddMealStep4Screen({super.key});

  Future<void> _createMeal(BuildContext context) async {
    final mealCreationProvider = context.read<MealCreationProvider>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final navigator = Navigator.of(context);

    await mealCreationProvider.createMeal();
    await weeklyMealsProvider.fetchMeals();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final servingsController = ValueNotifier(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add meal'),
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
                  SizedBox(height: 24),
                  FilledButton(
                      onPressed: () {
                        context
                            .read<MealCreationProvider>()
                            .setServings(servingsController.value);
                        _createMeal(context);
                      },
                      child: Text('Add meal'))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
