import '../../../infrastructure/helpers/i10n_helper.dart';

class Feces {
  int? id;
  String? title;
  String? description;
  String? image;

  Feces(this.id, this.title, this.description, this.image);

  static List<Feces> listOfAllFeces() {
    return [
      Feces(20, AppLocalizationsHelper.instance.translate('no_bowel_movement'), '', ''),
      Feces(21, AppLocalizationsHelper.instance.translate('type1_feces'), AppLocalizationsHelper.instance.translate('type1_feces_exp'), 'assets/images/diarrea_type1.png'),
      Feces(22, AppLocalizationsHelper.instance.translate('type2_feces'), AppLocalizationsHelper.instance.translate('type2_feces_exp'), 'assets/images/diarrea_type2.png'),
      Feces(23, AppLocalizationsHelper.instance.translate('type3_feces'), AppLocalizationsHelper.instance.translate('type3_feces_exp'), 'assets/images/diarrea_type3.png'),
      Feces(24, AppLocalizationsHelper.instance.translate('type4_feces'), AppLocalizationsHelper.instance.translate('type4_feces_exp'), 'assets/images/diarrea_type4.png'),
      Feces(25, AppLocalizationsHelper.instance.translate('type5_feces'), AppLocalizationsHelper.instance.translate('type5_feces_exp'), 'assets/images/diarrea_type5.png'),
      Feces(26, AppLocalizationsHelper.instance.translate('type6_feces'), AppLocalizationsHelper.instance.translate('type6_feces_exp'), 'assets/images/diarrea_type6.png'),
      Feces(27, AppLocalizationsHelper.instance.translate('type7_feces'), AppLocalizationsHelper.instance.translate('type7_feces_exp'), 'assets/images/diarrea_type7.png'),
    ];
  }
}