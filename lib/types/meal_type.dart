import 'package:toki_app/types/displayable.dart';

enum MealType implements Comparable<MealType>, Displayable {
  breakfast,
  lunch,
  dinner;

  @override
  int compareTo(MealType other) => index - other.index;

  @override
  String toString() {
    return switch (this) {
      MealType.breakfast => 'breakfast',
      MealType.lunch => 'lunch',
      MealType.dinner => 'dinner'
    };
  }

  @override
  String get displayName {
    return switch (this) {
      MealType.breakfast => 'Breakfast',
      MealType.lunch => 'Lunch',
      MealType.dinner => 'Dinner'
    };
  }

  static MealType fromString(String value) {
    return switch (value.toLowerCase()) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => throw ArgumentError('Invalid MealType value: $value')
    };
  }
}
