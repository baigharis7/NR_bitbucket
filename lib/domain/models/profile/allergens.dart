// ignore_for_file: overridden_fields
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Allergens {
  String? name;
  String? icon;
  int? id;

  Allergens(this.icon);

  static List<Allergens> listAllAllergens() {
    return [
      Crustaceans(icon: ''),
      Gluten(icon: ''),
      Eggs(icon: ''),
      Fish(icon: ''),
      Peanuts(icon: ''),
      Soy(icon: ''),
      Milk(icon: ''),
      Nuts(icon: ''),
      Celery(icon: ''),
      Mustard(icon: ''),
      Sesame(icon: ''),
      Sulphites(icon: ''),
      Lupins(icon: ''),
      Mollusks(icon: '')
    ];
  }

}

class Crustaceans extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('crustaceans');
  @override String? icon;
  @override int? id = 0;

  Crustaceans({this.icon}): super (icon);
}

class Gluten extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('gluten');
  @override String? icon;
  @override int? id = 1;

  Gluten({this.icon}): super (icon);

}

class Eggs extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('eggs');
  @override String? icon;
  @override int? id = 2;

  Eggs({this.icon}): super (icon);
}

class Fish extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('fish');
  @override String? icon;
  @override int? id = 3;

  Fish({this.icon}): super (icon);
}

class Peanuts extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('peanuts');
  @override String? icon;
  @override int? id = 4;

  Peanuts({this.icon}): super (icon);
}

class Soy extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('soy');
  @override String? icon;
  @override int? id = 5;

  Soy({this.icon}): super (icon);
}

class Milk extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('milk');
  @override String? icon;
  @override int? id = 6;

  Milk({this.icon}): super (icon);
}

class Nuts extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('nuts');
  @override String? icon;
  @override int? id = 7;

  Nuts({this.icon}): super (icon);
}

class Celery extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('celery');
  @override String? icon;
  @override int? id = 8;

  Celery({this.icon}): super (icon);
}

class Mustard extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('mustard');
  @override String? icon;
  @override int? id = 9;

  Mustard({this.icon}): super (icon);
}

class Sesame extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('sesame');
  @override String? icon;
  @override int? id = 10;

  Sesame({this.icon}): super (icon);
}

class Sulphites extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('sulphites');
  @override String? icon;
  @override int? id = 11;

  Sulphites({this.icon}): super (icon);
}

class Lupins extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('lupins');
  @override String? icon;
  @override int? id = 12;

  Lupins({this.icon}): super (icon);
}

class Mollusks extends Allergens {
  @override String? name = AppLocalizationsHelper.instance.translate('mollusks');
  @override String? icon;
  @override int? id = 13;

  Mollusks({this.icon}): super (icon);
}
