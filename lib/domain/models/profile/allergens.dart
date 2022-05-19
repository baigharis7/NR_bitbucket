// ignore_for_file: overridden_fields

import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class Allergens {
  String? name;
  String? icon;
  int? id;

  Allergens(this.name, this.icon);
  
  static List<Allergens> listAllAllergens() {
    return [
        Crustaceans(name: AppLocalizations.instance.translate('crustaceans'), icon: ''),
        Gluten(name: AppLocalizations.instance.translate('gluten'), icon: ''),
        Eggs(name: AppLocalizations.instance.translate('eggs'), icon: ''),
        Fish(name: AppLocalizations.instance.translate('fish'), icon: ''),
        Peanuts(name: AppLocalizations.instance.translate('peanuts'), icon: ''),
        Soy(name: AppLocalizations.instance.translate('soy'), icon: ''),
        Milk(name: AppLocalizations.instance.translate('milk'), icon: ''),
        Nuts(name: AppLocalizations.instance.translate('nuts'), icon: ''),
        Celery(name: AppLocalizations.instance.translate('celery'), icon: ''),
        Mustard(name: AppLocalizations.instance.translate('mustard'), icon: ''),
        Sesame(name: AppLocalizations.instance.translate('sesame'), icon: ''),
        Sulphites(name: AppLocalizations.instance.translate('sulphites'), icon: ''),
        Lupins(name: AppLocalizations.instance.translate('lupins'), icon: ''),
        Mollusks(name: AppLocalizations.instance.translate('mollusks'), icon: '')
    ];
  }

}

class Crustaceans extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 0;

  Crustaceans({this.name, this.icon}): super (name, icon);
}

class Gluten extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 1;

  Gluten({this.name, this.icon}): super (name, icon);

}

class Eggs extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 2;

  Eggs({this.name, this.icon}): super (name, icon);
}

class Fish extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 3;

  Fish({this.name, this.icon}): super (name, icon);
}

class Peanuts extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 4;

  Peanuts({this.name, this.icon}): super (name, icon);
}

class Soy extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 5;

  Soy({this.name, this.icon}): super (name, icon);
}

class Milk extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 6;

  Milk({this.name, this.icon}): super (name, icon);
}

class Nuts extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 7;

  Nuts({this.name, this.icon}): super (name, icon);
}

class Celery extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 8;

  Celery({this.name, this.icon}): super (name, icon);
}

class Mustard extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 9;

  Mustard({this.name, this.icon}): super (name, icon);
}

class Sesame extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 10;

  Sesame({this.name, this.icon}): super (name, icon);
}

class Sulphites extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 11;

  Sulphites({this.name, this.icon}): super (name, icon);
}

class Lupins extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 12;

  Lupins({this.name, this.icon}): super (name, icon);
}

class Mollusks extends Allergens {
  @override String? name;
  @override String? icon;
  @override int? id = 13;

  Mollusks({this.name, this.icon}): super (name, icon);
}
