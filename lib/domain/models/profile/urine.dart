import '../../../infrastructure/helpers/i10n_helper.dart';

class Urines {
  int? id;
  String? title;
  String? image;

  Urines(this.id, this.title, this.image);

  static List<Urines> listOfAllUrines(){
    return [
      Urines(0, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type1.png'),
      Urines(1, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type2.png'),
      Urines(2, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type3.png'),
      Urines(3, AppLocalizationsHelper.instance.translate('mild_dehydration'), 'assets/images/urine_type4.png'),
      Urines(4, AppLocalizationsHelper.instance.translate('medium_dehydration'), 'assets/images/urine_type5.png'),
      Urines(5, AppLocalizationsHelper.instance.translate('medium_dehydration'), 'assets/images/urine_type6.png'),
      Urines(6, AppLocalizationsHelper.instance.translate('high_dehydration'), 'assets/images/urine_type7.png'),
      Urines(7, AppLocalizationsHelper.instance.translate('high_dehydration'), 'assets/images/urine_type8.png'),
    ];
  }
}