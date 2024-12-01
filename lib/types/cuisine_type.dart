enum CuisineType {
  chinese,
  japanese,
  korean,
  vietnamese,
  thai,
  indian,
  indonesian,
  malaysian,
  filipino,
  singaporean,
  taiwanese,
  tibetan,
  nepalese,
  italian,
  french,
  spanish,
  greek,
  german,
  british,
  irish,
  portuguese,
  hungarian,
  polish,
  russian,
  swedish,
  norwegian,
  danish,
  dutch,
  belgian,
  swiss,
  austrian,
  turkish,
  lebanese,
  iranian,
  israeli,
  moroccan,
  egyptian,
  syrian,
  iraqi,
  saudi,
  american,
  mexican,
  brazilian,
  peruvian,
  argentinian,
  colombian,
  venezuelan,
  caribbean,
  cuban,
  cajun,
  creole,
  canadian,
  ethiopian,
  nigerian,
  southAfrican,
  kenyan,
  ghanaian,
  senegalese,
  tanzanian,
  other,
}

extension StringExtension on CuisineType {
  String get displayName {
    return switch (this) {
      CuisineType.chinese => 'chinese',
      CuisineType.japanese => 'japanese',
      CuisineType.korean => 'korean',
      CuisineType.vietnamese => 'vietnamese',
      CuisineType.thai => 'thai',
      CuisineType.indian => 'indian',
      CuisineType.indonesian => 'indonesian',
      CuisineType.malaysian => 'malaysian',
      CuisineType.filipino => 'filipino',
      CuisineType.singaporean => 'singaporean',
      CuisineType.taiwanese => 'taiwanese',
      CuisineType.tibetan => 'tibetan',
      CuisineType.nepalese => 'nepalese',
      CuisineType.italian => 'italian',
      CuisineType.french => 'french',
      CuisineType.spanish => 'spanish',
      CuisineType.greek => 'greek',
      CuisineType.german => 'german',
      CuisineType.british => 'british',
      CuisineType.irish => 'irish',
      CuisineType.portuguese => 'portuguese',
      CuisineType.hungarian => 'hungarian',
      CuisineType.polish => 'polish',
      CuisineType.russian => 'russian',
      CuisineType.swedish => 'swedish',
      CuisineType.norwegian => 'norwegian',
      CuisineType.danish => 'danish',
      CuisineType.dutch => 'dutch',
      CuisineType.belgian => 'belgian',
      CuisineType.swiss => 'swiss',
      CuisineType.austrian => 'austrian',
      CuisineType.turkish => 'turkish',
      CuisineType.lebanese => 'lebanese',
      CuisineType.iranian => 'iranian',
      CuisineType.israeli => 'israeli',
      CuisineType.moroccan => 'moroccan',
      CuisineType.egyptian => 'egyptian',
      CuisineType.syrian => 'syrian',
      CuisineType.iraqi => 'iraqi',
      CuisineType.saudi => 'saudi',
      CuisineType.american => 'american',
      CuisineType.mexican => 'mexican',
      CuisineType.brazilian => 'brazilian',
      CuisineType.peruvian => 'peruvian',
      CuisineType.argentinian => 'argentinian',
      CuisineType.colombian => 'colombian',
      CuisineType.venezuelan => 'venezuelan',
      CuisineType.caribbean => 'caribbean',
      CuisineType.cuban => 'cuban',
      CuisineType.cajun => 'cajun',
      CuisineType.creole => 'creole',
      CuisineType.canadian => 'canadian',
      CuisineType.ethiopian => 'ethiopian',
      CuisineType.nigerian => 'nigerian',
      CuisineType.southAfrican => 'southAfrican',
      CuisineType.kenyan => 'kenyan',
      CuisineType.ghanaian => 'ghanaian',
      CuisineType.senegalese => 'senegalese',
      CuisineType.tanzanian => 'tanzanian',
      CuisineType.other => 'other',
    };
  }
}

extension CuisineTypeExtension on CuisineType {
  static CuisineType fromString(String value) {
    return switch (value.toLowerCase()) {
      'chinese' => CuisineType.chinese,
      'japanese' => CuisineType.japanese,
      'korean' => CuisineType.korean,
      'vietnamese' => CuisineType.vietnamese,
      'thai' => CuisineType.thai,
      'indian' => CuisineType.indian,
      'indonesian' => CuisineType.indonesian,
      'malaysian' => CuisineType.malaysian,
      'filipino' => CuisineType.filipino,
      'singaporean' => CuisineType.singaporean,
      'taiwanese' => CuisineType.taiwanese,
      'tibetan' => CuisineType.tibetan,
      'nepalese' => CuisineType.nepalese,
      'italian' => CuisineType.italian,
      'french' => CuisineType.french,
      'spanish' => CuisineType.spanish,
      'greek' => CuisineType.greek,
      'german' => CuisineType.german,
      'british' => CuisineType.british,
      'irish' => CuisineType.irish,
      'portuguese' => CuisineType.portuguese,
      'hungarian' => CuisineType.hungarian,
      'polish' => CuisineType.polish,
      'russian' => CuisineType.russian,
      'swedish' => CuisineType.swedish,
      'norwegian' => CuisineType.norwegian,
      'danish' => CuisineType.danish,
      'dutch' => CuisineType.dutch,
      'belgian' => CuisineType.belgian,
      'swiss' => CuisineType.swiss,
      'austrian' => CuisineType.austrian,
      'turkish' => CuisineType.turkish,
      'lebanese' => CuisineType.lebanese,
      'iranian' => CuisineType.iranian,
      'israeli' => CuisineType.israeli,
      'moroccan' => CuisineType.moroccan,
      'egyptian' => CuisineType.egyptian,
      'syrian' => CuisineType.syrian,
      'iraqi' => CuisineType.iraqi,
      'saudi' => CuisineType.saudi,
      'american' => CuisineType.american,
      'mexican' => CuisineType.mexican,
      'brazilian' => CuisineType.brazilian,
      'peruvian' => CuisineType.peruvian,
      'argentinian' => CuisineType.argentinian,
      'colombian' => CuisineType.colombian,
      'venezuelan' => CuisineType.venezuelan,
      'caribbean' => CuisineType.caribbean,
      'cuban' => CuisineType.cuban,
      'cajun' => CuisineType.cajun,
      'creole' => CuisineType.creole,
      'canadian' => CuisineType.canadian,
      'ethiopian' => CuisineType.ethiopian,
      'nigerian' => CuisineType.nigerian,
      'southAfrican' => CuisineType.southAfrican,
      'kenyan' => CuisineType.kenyan,
      'ghanaian' => CuisineType.ghanaian,
      'senegalese' => CuisineType.senegalese,
      'tanzanian' => CuisineType.tanzanian,
      'other' => CuisineType.other,
      _ => throw ArgumentError('Invalid CuisineType value: $value')
    };
  }
}
