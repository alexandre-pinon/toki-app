import 'package:toki_app/errors/expected_error.dart';
import 'package:toki_app/hive/types/weekday.dart';
import 'package:toki_app/types/meal_type.dart';

class MealAlreadyExist extends ExpectedError {
  MealAlreadyExist(
    Weekday day,
    MealType type,
  ) : super('Another meal is already planned for $type on $day');
}
