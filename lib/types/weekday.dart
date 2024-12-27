enum Weekday implements Comparable<Weekday> {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  @override
  int compareTo(Weekday other) => index - other.index;

  factory Weekday.fromDatetimeWeekday(int value) {
    return switch (value) {
      DateTime.monday => Weekday.monday,
      DateTime.tuesday => Weekday.tuesday,
      DateTime.wednesday => Weekday.wednesday,
      DateTime.thursday => Weekday.thursday,
      DateTime.friday => Weekday.friday,
      DateTime.saturday => Weekday.saturday,
      DateTime.sunday => Weekday.sunday,
      _ => throw ArgumentError('Invalid Weekday value: $value')
    };
  }
}

extension StringExtension on Weekday {
  String get displayName {
    return switch (this) {
      Weekday.monday => 'Monday',
      Weekday.tuesday => 'Tuesday',
      Weekday.wednesday => 'Wednesday',
      Weekday.thursday => 'Thursday',
      Weekday.friday => 'Friday',
      Weekday.saturday => 'Saturday',
      Weekday.sunday => 'Sunday',
    };
  }
}
