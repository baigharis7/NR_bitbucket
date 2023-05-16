import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Intolerances {
  String? name;
  int? id;

  Intolerances({required this.name, required this.id});

  static List<Intolerances> listAllIntolerances() {
    return [
      Lactose(),
      Fructose(),
      Sorbitol(),
    ];
  }
}

class Lactose extends Intolerances {
  Lactose(): super(
    name: AppLocalizationsHelper.instance.translate('lactose'),
    id: 0,
  );
}

class Fructose extends Intolerances {
  Fructose(): super(
    name: AppLocalizationsHelper.instance.translate('fructose'),
    id: 1,
  );
}

class Sorbitol extends Intolerances {
  Sorbitol(): super(
    name: AppLocalizationsHelper.instance.translate('sorbitol'),
    id: 2,
  );
}