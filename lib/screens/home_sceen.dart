import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/screens/login_screen.dart';
import 'package:toki_app/screens/meal_screen.dart';
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
    DateTime from = DateTime.utc(now.year, now.month, now.day);
    DateTime to = from.add(Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Weekly meals'),
      ),
      body: FutureBuilder(
        future: context
            .read<PlannedMealService>()
            .fetchWeeklyPlannedMeals(from, to),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (snapshot.error is Unauthenticated) {
              context.read<AuthProvider>().logout();
            } else {
              showGlobalSnackBar(snapshot.error.toString());
            }

            return Center(child: CircularProgressIndicator());
          }

          final mealsByDay = groupBy(snapshot.data!, (meal) => meal.mealDate);
          return ListView(
            children: mealsByDay.entries
                .sortedBy((entry) => entry.key) // by meal date
                .map((entry) => DayMeals(
                      day: WeekdayExtension.fromDatetimeWeekday(
                        entry.key.weekday,
                      ),
                      meals: entry.value,
                    ))
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
                  title: Text(meal.title ?? 'Meal'),
                  subtitle: Text(meal.mealType.displayName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MealScreen(meal)),
                    );
                  },
                ),
              ),
            ),
      ],
    );
  }
}
