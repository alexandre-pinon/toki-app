import 'package:hive_flutter/hive_flutter.dart';

part 'unit_type.g.dart';

@HiveType(typeId: 1)
enum UnitType {
  @HiveField(0)
  ml,
  @HiveField(1)
  cl,
  @HiveField(2)
  dl,
  @HiveField(3)
  l,
  @HiveField(4)
  g,
  @HiveField(5)
  kg,
  @HiveField(6)
  tsp,
  @HiveField(7)
  tbsp,
  @HiveField(8)
  cup,
  @HiveField(9)
  piece,
  @HiveField(10)
  pinch,
  @HiveField(11)
  bunch,
  @HiveField(12)
  clove,
  @HiveField(13)
  can,
  @HiveField(14)
  package,
  @HiveField(15)
  slice,
  @HiveField(16)
  totaste,
  @HiveField(17)
  unit;

  @override
  String toString() {
    return switch (this) {
      UnitType.ml => 'ml',
      UnitType.cl => 'cl',
      UnitType.dl => 'dl',
      UnitType.l => 'l',
      UnitType.g => 'g',
      UnitType.kg => 'kg',
      UnitType.tsp => 'tsp',
      UnitType.tbsp => 'tbsp',
      UnitType.cup => 'cup',
      UnitType.piece => 'piece',
      UnitType.pinch => 'pinch',
      UnitType.bunch => 'bunch',
      UnitType.clove => 'clove',
      UnitType.can => 'can',
      UnitType.package => 'package',
      UnitType.slice => 'slice',
      UnitType.totaste => 'to taste',
      UnitType.unit => 'unit',
    };
  }

  factory UnitType.fromString(String value) {
    return switch (value.toLowerCase()) {
      'ml' => UnitType.ml,
      'cl' => UnitType.cl,
      'dl' => UnitType.dl,
      'l' => UnitType.l,
      'g' => UnitType.g,
      'kg' => UnitType.kg,
      'tsp' => UnitType.tsp,
      'tbsp' => UnitType.tbsp,
      'cup' => UnitType.cup,
      'piece' => UnitType.piece,
      'pinch' => UnitType.pinch,
      'bunch' => UnitType.bunch,
      'clove' => UnitType.clove,
      'can' => UnitType.can,
      'package' => UnitType.package,
      'slice' => UnitType.slice,
      'to taste' => UnitType.totaste,
      'unit' => UnitType.unit,
      _ => throw ArgumentError('Invalid UnitType value: $value')
    };
  }
}

extension StringExtension on UnitType {
  String get displayName {
    return switch (this) {
      UnitType.ml => 'ml',
      UnitType.cl => 'cl',
      UnitType.dl => 'dl',
      UnitType.l => 'l',
      UnitType.g => 'g',
      UnitType.kg => 'kg',
      UnitType.tsp => 'cuillère à café',
      UnitType.tbsp => 'cuillère à soupe',
      UnitType.cup => 'tasse',
      UnitType.piece => 'pièce',
      UnitType.pinch => 'pincée',
      UnitType.bunch => 'botte',
      UnitType.clove => 'gousse',
      UnitType.can => 'boîte',
      UnitType.package => 'sachet',
      UnitType.slice => 'tranche',
      UnitType.totaste => 'selon le goût',
      UnitType.unit => 'unité',
    };
  }
}
