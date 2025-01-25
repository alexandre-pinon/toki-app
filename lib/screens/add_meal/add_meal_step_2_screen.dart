import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/hive/types/weekday.dart';
import 'package:toki_app/providers/meal_creation_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_3_screen.dart';

class AddMealStep2Screen extends StatelessWidget {
  const AddMealStep2Screen({super.key});

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
                    'For which day of the week?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: Weekday.values
                        .map(
                          (day) => ActionChip(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: CircleBorder(),
                            label: Text(day.minifiedDisplayName),
                            onPressed: () {
                              context
                                  .read<MealCreationProvider>()
                                  .setMealDate(day.toClosestDate());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMealStep3Screen(),
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
