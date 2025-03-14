import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/hive/types/weekday.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/user_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/meal_screen.dart';
import 'package:toki_app/services/planned_meal_service.dart';

class WeeklyMeals extends StatelessWidget {
  const WeeklyMeals({super.key});

  @override
  Widget build(BuildContext context) {
    final loggerInUser = context.watch<UserProvider>().user;
    final weeklyMealsProvider = context.watch<WeeklyMealsProvider>();

    if (weeklyMealsProvider.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (weeklyMealsProvider.meals.isEmpty) {
      return Center(
        child: Text(
          loggerInUser != null
              ? 'No meals planned for this week'
              : 'Connect to internet to see your planned meals',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      );
    }

    final mealsByDay = groupBy(
      weeklyMealsProvider.meals,
      (meal) => meal.mealDate,
    );
    return ListView(
      children: mealsByDay.entries
          .sortedBy((entry) => entry.key) // by meal date
          .map((entry) => DayMeals(
                day: Weekday.fromDatetimeWeekday(
                  entry.key.weekday,
                ),
                meals: entry.value,
              ))
          .toList(),
    );
  }
}

class DayMeals extends StatelessWidget {
  final Weekday day;
  final List<WeeklyPlannedMeal> meals;

  const DayMeals({super.key, required this.day, required this.meals});

  Future<void> _deleteMeal(BuildContext context, String mealId) async {
    final mealService = context.read<PlannedMealService>();
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();

    await mealService.deletePlannedMeal(mealId);
    await weeklyMealsProvider.fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(day.displayName),
        ),
        ...meals.sortedBy((meal) => meal.mealType).map(
              (meal) => Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Dismissible(
                  key: ValueKey(meal.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) {
                    final mealTitle = meal.title.toLowerCase();
                    final weekDay = day.displayName.toLowerCase();
                    return showConfirmationDialog(
                      context: context,
                      title: 'Remove $mealTitle from $weekDay meals?',
                    );
                  },
                  onDismissed: (direction) {
                    _deleteMeal(context, meal.id);
                  },
                  dismissThresholds: {DismissDirection.endToStart: 0.2},
                  background: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.error,
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(Icons.delete),
                  ),
                  child: Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: meal.id,
                          child: meal.imageUrl != null
                              ? Image.network(meal.imageUrl!)
                              : Image.asset(
                                  'assets/images/${meal.mealType}.png',
                                  width: 64,
                                  height: 64,
                                ),
                        ),
                      ),
                      title: Text(meal.title),
                      subtitle: Text(meal.mealType.displayName),
                      onTap: () {
                        context.read<MealProvider>().resetData();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MealScreen(meal),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
