import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/user_provider.dart';
import 'package:toki_app/screens/add_meal/add_meal_step_1_screen.dart';
import 'package:toki_app/screens/profile_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final loggerInUser = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            'Weekly meals',
            'Shopping list',
          ][currentPageIndex],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (loggerInUser != null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                child: Text(loggerInUser.initials),
              ),
            )
        ],
      ),
      body: [
        WeeklyMeals(),
        ShoppingList(),
      ][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: loggerInUser == null ? Colors.grey[300] : null,
        onPressed: loggerInUser != null
            ? () {
                switch (currentPageIndex) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddMealStep1Screen()),
                    );
                  case 1:
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ShoppingListItemForm(),
                    );
                }
              }
            : null,
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
