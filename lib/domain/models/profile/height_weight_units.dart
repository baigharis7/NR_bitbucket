import '../../../infrastructure/helpers/i10n_helper.dart';

class HeightWeightUnits {
  String? height;
  String? weight;
  int? id;
  String? unit;

  HeightWeightUnits({this.height, this.weight, this.id, this.unit});

  static List<HeightWeightUnits> getAllUnits() {
    return [
      CmKg(),
      FeetLb(),
    ];
  }
}

class CmKg extends HeightWeightUnits {
  CmKg()
      : super(
          height: AppLocalizationsHelper.instance.translate('height_cm'),
          weight: AppLocalizationsHelper.instance.translate('weight_kg'),
          id: 1,
          unit: 'cm - kg',
        );
}

class FeetLb extends HeightWeightUnits {
  FeetLb()
      : super(
          height: AppLocalizationsHelper.instance.translate('height_feet'),
          weight: AppLocalizationsHelper.instance.translate('weight_lb'),
          id: 2,
          unit: 'feet - lb',
        );
}
