import 'package:flutter/material.dart';

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

  @override
  String toString() {
    return switch (this) {
      Weekday.monday => 'monday',
      Weekday.tuesday => 'tuesday',
      Weekday.wednesday => 'wednesday',
      Weekday.thursday => 'thursday',
      Weekday.friday => 'friday',
      Weekday.saturday => 'saturday',
      Weekday.sunday => 'sunday',
    };
  }

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

  factory Weekday.fromString(String value) {
    return switch (value.toLowerCase()) {
      "monday" => Weekday.monday,
      "tuesday" => Weekday.tuesday,
      "wednesday" => Weekday.wednesday,
      "thursday" => Weekday.thursday,
      "friday" => Weekday.friday,
      "saturday" => Weekday.saturday,
      "sunday" => Weekday.sunday,
      _ => throw ArgumentError('Invalid Weekday value: $value')
    };
  }

  DateTime toClosestDate() {
    var dateTime = DateTime.now();

    while (dateTime.weekday != index + 1) {
      dateTime = dateTime.add(Duration(days: 1));
    }

    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
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

  String get minifiedDisplayName {
    return switch (this) {
      Weekday.monday => 'Mon',
      Weekday.tuesday => 'Tue',
      Weekday.wednesday => 'Wed',
      Weekday.thursday => 'Thu',
      Weekday.friday => 'Fri',
      Weekday.saturday => 'Sat',
      Weekday.sunday => 'Sun',
    };
  }
}

extension WeekdayColor on Weekday {
  Color? get backgroundColor {
    return {
      Weekday.monday: Colors.blue[50],
      Weekday.tuesday: Colors.green[50],
      Weekday.wednesday: Colors.orange[50],
      Weekday.thursday: Colors.purple[50],
      Weekday.friday: Colors.pink[50],
      Weekday.saturday: Colors.yellow[50],
      Weekday.sunday: Colors.red[50],
    }[this];
  }
}
