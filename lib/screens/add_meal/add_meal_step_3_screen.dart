import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_4_screen.dart';
import 'package:toki_app/types/meal_type.dart';

class AddMealStep3Screen extends StatelessWidget {
  const AddMealStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'For which meal?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 6,
                    children: MealType.values
                        .map(
                          (mealType) => ActionChip(
                            label: Text(mealType.displayName),
                            onPressed: () {
                              context
                                  .read<MealCreationProvider>()
                                  .setMealType(mealType);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMealStep4Screen(),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
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
