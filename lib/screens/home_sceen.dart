import 'package:flutter/material.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/weekly_meals_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_1_screen.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/widgets/shopping_list.dart';
import 'package:toki_app/widgets/shopping_list_item_form.dart';
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
          switch (currentPageIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMealStep1Screen()),
              );
            case 1:
              showModalBottomSheet(
                context: context,
                builder: (context) => ShoppingListItemForm(),
              );
          }
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
