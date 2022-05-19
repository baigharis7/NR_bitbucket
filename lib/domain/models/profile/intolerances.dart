// ignore_for_file: overridden_fields

import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Intolerances {
  String? name;
  String? icon;
  int? id;

  Intolerances(this.name, this.icon);

  static List<Intolerances> listAllIntolerances() {
    return [
      Lactose(name: AppLocalizations.instance.translate('lactose'), icon: ''),
      Fructose(name: AppLocalizations.instance.translate('fructose'), icon: ''),
      Sorbitol(name: AppLocalizations.instance.translate('sorbitol'), icon: ''),
    ];
  }

}

class Lactose extends Intolerances {
  @override String? name;
  @override String? icon;
  @override int? id = 0;

  Lactose({this.name, this.icon}): super (name, icon);
}

class Fructose extends Intolerances {
  @override String? name;
  @override String? icon;
  @override int? id = 1;

  Fructose({this.name, this.icon}): super (name, icon);

}

class Sorbitol extends Intolerances {
  @override String? name;
  @override String? icon;
  @override int? id = 2;

  Sorbitol({this.name, this.icon}): super (name, icon);
}