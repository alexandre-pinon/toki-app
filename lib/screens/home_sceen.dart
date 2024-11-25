import 'package:flutter/material.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/types/meal_type.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - DateTime.monday),
    );
    DateTime endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).add(
      Duration(days: 6),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Weekly meals'),
      ),
      body: FutureBuilder(
        future: context
            .read<PlannedMealService>()
            .fetchWeeklyPlannedMeals(startOfWeek, endOfWeek),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: $snapshot.error'));
          }

          final mealsByDay = groupBy(
            snapshot.data!,
            (meal) => WeekdayExtension.fromDatetimeWeekday(
              meal.mealDate.weekday,
            ),
          );
          return ListView(
            children: mealsByDay.entries
                .sortedBy((entry) => entry.key)
                .map((entry) => DayMeals(day: entry.key, meals: entry.value))
                .toList(),
          );
        },
      ),
    );
  }
}

class DayMeals extends StatelessWidget {
  final Weekday day;
  final List<PlannedMeal> meals;

  const DayMeals({super.key, required this.day, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(day.displayName),
        ),
        ...meals.sortedBy((meal) => meal.mealType).map(
              (meal) => Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      meal.imageUrl ?? 'https://placehold.co/64.png',
                    ),
                  ),
                  title: Text(meal.title),
                  subtitle: Text(meal.mealType.displayName),
                ),
              ),
            ),
      ],
    );
  }
}
