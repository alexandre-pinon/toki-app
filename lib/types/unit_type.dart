enum UnitType {
  ml,
  cl,
  dl,
  l,
  g,
  kg,
  tsp,
  tbsp,
  cup,
  piece,
  pinch,
  bunch,
  clove,
  can,
  package,
  slice,
  totaste,
  unit,
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
}

extension UnitTypeExtension on UnitType {
  static UnitType fromString(String value) {
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
