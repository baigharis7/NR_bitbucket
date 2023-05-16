class ExplainingCardModel {
  int id;
  String name;
  String upperText;
  String? lowerText;
  String? buttonText;
  Function? onPressedButton;

  ExplainingCardModel({
    required this.id,
    required this.name,
    required this.upperText,
    this.lowerText,
    this.buttonText,
    this.onPressedButton,
  });
}

enum ExplainingCardRefs {
  dashboard,
  journalGeneral,
  journalCalendar,
  journalFoods,
  journalLiquids,
  journalSports,
  addNewFoodEvent,
  addNewLiquidEvent,
  addNewSportEvent,
  addFoodFavorite,
  addSportFavorite,
  recommendations,
  recipes,
  foodList,
}