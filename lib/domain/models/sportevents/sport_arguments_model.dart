class SportArgumentsModel {
  final DateTime selectedDateTime;
  final bool preSelectFavorite;
  final bool preSelectRoutine;

  SportArgumentsModel({
    required this.selectedDateTime,
    this.preSelectFavorite = false,
    this.preSelectRoutine = false,
  });
}
