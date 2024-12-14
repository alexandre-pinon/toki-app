import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/meal_screen.dart';
import 'package:toki_app/types/meal_type.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
      final authProvider = context.read<AuthProvider>();

      try {
        await weeklyMealsProvider.fetchMeals();
      } on Unauthenticated {
        await authProvider.logout();
      } catch (error) {
        showGlobalSnackBar(error.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Weekly meals'),
      ),
      body: Builder(
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
  final List<WeeklyPlannedMeal> meals;

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
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      meal.imageUrl ?? 'https://placehold.co/64.png',
                    ),
                  ),
                  title: Text(meal.title),
                  subtitle: Text(meal.mealType.displayName),
                  onTap: () {
                    context.read<MealProvider>().resetData();
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
