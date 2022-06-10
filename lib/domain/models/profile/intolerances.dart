// ignore_for_file: overridden_fields
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Intolerances {
  String? name;
  String? icon;
  int? id;

  Intolerances(this.icon);

  static List<Intolerances> listAllIntolerances() {
    return [
      Lactose(icon: ''),
      Fructose(icon: ''),
      Sorbitol(icon: ''),
    ];
  }
}

class Lactose extends Intolerances {
  @override String? name = AppLocalizationsHelper.instance.translate('lactose');
  @override String? icon;
  @override int? id = 0;

  Lactose({this.icon}): super (icon);
}

class Fructose extends Intolerances {
  @override String? name = AppLocalizationsHelper.instance.translate('fructose');
  @override String? icon;
  @override int? id = 1;

  Fructose({this.icon}): super (icon);

}

class Sorbitol extends Intolerances {
  @override String? name = AppLocalizationsHelper.instance.translate('sorbitol');
  @override String? icon;
  @override int? id = 2;

  Sorbitol({this.icon}): super (icon);
}