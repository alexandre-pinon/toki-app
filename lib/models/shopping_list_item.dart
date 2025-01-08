import 'package:toki_app/types/unit_type.dart';
import 'package:toki_app/types/weekday.dart';

class ShoppingListItem {
  final List<String> ids;
  final bool checked;
  final String name;
  final double? quantity;
  final UnitType? unit;
  final Weekday? weekday;
  final DateTime? mealDate;

  ShoppingListItem({
    required this.ids,
    required this.checked,
    required this.name,
    this.quantity,
    this.unit,
    this.weekday,
    this.mealDate,
  });

  ShoppingListItem.fromJson(dynamic json)
      : ids =
            (json['ids'] as List<dynamic>).map((id) => id.toString()).toList(),
        checked = json['checked'],
        name = json['name'],
        quantity = json['quantity'],
        unit = json['unit'] != null ? UnitType.fromString(json['unit']) : null,
        weekday = json['week_day'] != null
            ? Weekday.fromString(json['week_day'])
            : null,
        mealDate = json['meal_date'] != null
            ? DateTime.parse(json['meal_date']).copyWith(isUtc: true)
            : null; // force date parse as UTC
}
