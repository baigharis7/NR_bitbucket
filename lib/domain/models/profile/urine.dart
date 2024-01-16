import '../../../infrastructure/helpers/i10n_helper.dart';

class Urines {
  int? id;
  String? title;
  String? image;

  Urines(this.id, this.title, this.image);

  static List<Urines> listOfAllUrines(){
    return [
      Urines(30, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type1.png'),
      Urines(31, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type2.png'),
      Urines(32, AppLocalizationsHelper.instance.translate('good_hydration'), 'assets/images/urine_type3.png'),
      Urines(33, AppLocalizationsHelper.instance.translate('mild_dehydration'), 'assets/images/urine_type4.png'),
      Urines(34, AppLocalizationsHelper.instance.translate('medium_dehydration'), 'assets/images/urine_type5.png'),
      Urines(35, AppLocalizationsHelper.instance.translate('medium_dehydration'), 'assets/images/urine_type6.png'),
      Urines(36, AppLocalizationsHelper.instance.translate('high_dehydration'), 'assets/images/urine_type7.png'),
      Urines(37, AppLocalizationsHelper.instance.translate('high_dehydration'), 'assets/images/urine_type8.png'),
    ];
  }
}