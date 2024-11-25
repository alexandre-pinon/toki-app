enum MealType implements Comparable<MealType> {
  breakfast,
  lunch,
  dinner;

  @override
  int compareTo(MealType other) => index - other.index;
}

extension StringExtension on MealType {
  String get displayName {
    return switch (this) {
      MealType.breakfast => 'Breakfast',
      MealType.lunch => 'Lunch',
      MealType.dinner => 'Dinner'
    };
  }
}

extension MealTypeExtension on MealType {
  static MealType fromString(String value) {
    return switch (value.toLowerCase()) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => throw ArgumentError('Invalid MealType value: $value')
    };
  }
}
