// ignore_for_file: overridden_fields
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Allergens {
  String? name;
  String? icon;
  int? id;

  Allergens({this.name, this.icon, this.id});

  static List<Allergens> listAllAllergens() {
    return [
      Crustaceans(),
      Gluten(),
      Eggs(),
      Fish(),
      Peanuts(),
      Soy(),
      Milk(),
      Nuts(),
      Celery(),
      Mustard(),
      Sesame(),
      Sulfites(),
      Lupins(),
      Mollusks()
    ];
  }

}

class Crustaceans extends Allergens {
  Crustaceans(): super(
    name: AppLocalizationsHelper.instance.translate('crustaceans'), 
    id: 0, 
    icon: 'assets/icon/crustaceans_icon.png',
  );
}

class Gluten extends Allergens {
  Gluten(): super(
    name: AppLocalizationsHelper.instance.translate('gluten'),
    id: 1,
    icon: 'assets/icon/meat_icon.png',
    // icon: 'assets/icon/gluten_icon.png',
  );
}

class Eggs extends Allergens {
  Eggs(): super(
    name: AppLocalizationsHelper.instance.translate('eggs'),
    id: 2,
    icon: 'assets/icon/eggs_icon.png',
  );
}

class Fish extends Allergens {
  Fish(): super(
    name: AppLocalizationsHelper.instance.translate('fish'),
    id: 3,
    icon: 'assets/icon/meat_icon.png',
    // icon: 'assets/icon/fish_icon.png',
  );
}

class Peanuts extends Allergens {
  Peanuts(): super(
    name: AppLocalizationsHelper.instance.translate('peanuts'),
    id: 4,
    icon: 'assets/icon/peanuts_icon.png',
  );
}

class Soy extends Allergens {
  Soy(): super(
    name: AppLocalizationsHelper.instance.translate('soy'),
    id: 5,
    icon: 'assets/icon/soy_icon.png',
  );
}

class Milk extends Allergens {
  Milk(): super(
    name: AppLocalizationsHelper.instance.translate('milk'),
    id: 6,
    icon: 'assets/icon/dairy_icon.png',
  );
}

class Nuts extends Allergens {
  Nuts(): super(
    name: AppLocalizationsHelper.instance.translate('nuts'),
    id: 7,
    icon: 'assets/icon/nuts_icon.png',
  );
}

class Celery extends Allergens {
  Celery(): super(
    name: AppLocalizationsHelper.instance.translate('celery'),
    id: 8,
    icon: 'assets/icon/celery_icon.png',
  );
}

class Mustard extends Allergens {
  Mustard(): super(
    name: AppLocalizationsHelper.instance.translate('mustard'),
    id: 9,
    // icon: 'assets/icon/mustard_icon.png',
    icon: 'assets/icon/meat_icon.png',
  );
}

class Sesame extends Allergens {
  Sesame(): super(
    name: AppLocalizationsHelper.instance.translate('sesame'),
    id: 10,
    icon: 'assets/icon/sesame_icon.png',
  );
}

class Sulfites extends Allergens {
  Sulfites(): super(
    name: AppLocalizationsHelper.instance.translate('sulfites'),
    id: 11,
    icon: 'assets/icon/sulfites_icon.png',
  );
}

class Lupins extends Allergens {
  Lupins(): super(
    name: AppLocalizationsHelper.instance.translate('lupins'),
    id: 12,
    // icon: 'assets/icon/lupins_icon.png',
    icon: 'assets/icon/meat_icon.png',
  );
}

class Mollusks extends Allergens {
  Mollusks(): super(
    name: AppLocalizationsHelper.instance.translate('mollusks'),
    id: 13,
    // icon: 'assets/icon/mollusks_icon.png',
    icon: 'assets/icon/meat_icon.png',
  );
}
