import 'package:hive/hive.dart';
import 'package:toki_app/hive/types/unit_type.dart';
import 'package:toki_app/hive/types/weekday.dart';

part 'shopping_list_item.g.dart';

@HiveType(typeId: 0)
class ShoppingListItem extends HiveObject
    implements Comparable<ShoppingListItem> {
  @HiveField(0)
  final List<String> ids;
  @HiveField(1)
  final bool checked;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final double? quantity;
  @HiveField(4)
  final UnitType? unit;
  @HiveField(5)
  final Weekday? weekday;
  @HiveField(6)
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

  ShoppingListItem copyWith({
    List<String>? ids,
    bool? checked,
    String? name,
    double? quantity,
    UnitType? unit,
    Weekday? weekday,
    DateTime? mealDate,
  }) {
    return ShoppingListItem(
      ids: ids ?? this.ids,
      checked: checked ?? this.checked,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      weekday: weekday ?? this.weekday,
      mealDate: mealDate ?? this.mealDate,
    );
  }

  bool get canBeEdited =>
      mealDate == null && weekday == null && ids.length == 1;

  bool get canBeDeleted =>
      mealDate == null && weekday == null && ids.length == 1;

  @override
  int compareTo(ShoppingListItem other) {
    return compareByCheckedAndDate(this, other);
  }

  static int compareByCheckedAndDate(ShoppingListItem a, ShoppingListItem b) {
    // First sort by checked status
    if (a.checked != b.checked) {
      return a.checked ? 1 : -1;
    }
    // Then sort by meal date, nulls first
    if (a.mealDate == null && b.mealDate != null) return -1;
    if (a.mealDate != null && b.mealDate == null) return 1;
    if (a.mealDate != null && b.mealDate != null) {
      return a.mealDate!.compareTo(b.mealDate!);
    }
    return 0;
  }
}
