import 'package:toki_app/models/planned_meal.dart';
import 'package:toki_app/providers/loading_change_notifier.dart';
import 'package:toki_app/services/planned_meal_service.dart';

class WeeklyMealsProvider extends LoadingChangeNotifier {
  final PlannedMealService mealService;

  WeeklyMealsProvider({required this.mealService});

  List<WeeklyPlannedMeal> _meals = [];
  List<WeeklyPlannedMeal> get meals => _meals;

  Future<void> fetchMeals() async {
    await withLoading(() async {
      DateTime now = DateTime.now();
      DateTime from = DateTime.utc(now.year, now.month, now.day);
      DateTime to = from.add(Duration(days: 6));

      _meals = await mealService.fetchWeeklyPlannedMeals(from, to);
    });
  }
}
