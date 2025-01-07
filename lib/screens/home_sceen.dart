import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/meal_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_1_screen.dart';
import 'package:toki_app/screens/meal_screen.dart';
import 'package:toki_app/services/planned_meal_service.dart';
import 'package:toki_app/types/weekday.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:toki_app/widgets/shopping_list.dart';
import 'package:toki_app/widgets/weekly_meals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  Future<void> fetchMealData() async {
    final weeklyMealsProvider = context.read<WeeklyMealsProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      await weeklyMealsProvider.fetchMeals();
    } on Unauthenticated {
      await authProvider.logout();
    } catch (error) {
      showGlobalSnackBar(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchMealData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text([
          'Weekly meals',
          'Shopping list',
        ][currentPageIndex]),
      ),
      body: [
        WeeklyMeals(),
        ShoppingList(),
      ][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMealStep1Screen()),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Weekly meals',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_cart),
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Shopping list',
          )
        ],
      ),
    );
  }
}
