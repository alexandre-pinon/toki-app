import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/meal_screen.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class WeeklyMeals extends StatefulWidget {
  const WeeklyMeals({super.key});

  @override
  State<WeeklyMeals> createState() => _WeeklyMealsState();
}

class _WeeklyMealsState extends State<WeeklyMeals> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchMealData);
  }

  Future<void> _fetchMealData() async {
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await weeklyMealsProvider.fetchMeals();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final weeklyMealsProvider = context.watch<WeeklyMealsProvider>();

        if (weeklyMealsProvider.loading) {
          return Center(child: CircularProgressIndicator());
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
      },
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
    final authProvider = context.read<AuthProvider>();

    try {
      await mealService.deletePlannedMeal(mealId);
      await weeklyMealsProvider.fetchMeals();
    } on Unauthenticated {
      await authProvider.logout();
    }
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
