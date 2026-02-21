import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/favorites/sport/sport_favorite.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';

class SportEventItem extends StatefulWidget {
  final List<SportInfoMaster> allSportsInfo;
  final AddSportFavInfo sport;
  final Function removeSport;
  final Function(AddSportFavInfo) editMinutes;
  final Function(AddSportFavInfo) editIntensity;
  final bool showValidation;
  const SportEventItem({
    Key? key,
    required this.allSportsInfo,
    required this.sport,
    required this.removeSport,
    required this.editMinutes,
    required this.editIntensity,
    this.showValidation = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SportEventItem();
}

class _SportEventItem extends State<SportEventItem> {
  String? _sportName;
  int? _sportIntensities;
  int? _duration;
  int? _intensity;
  bool _error = false;
  final _durationTextController = TextEditingController();

  List<String> getIntensityList(int itemsNumber, BuildContext context) {
    final List<String> intensities = [];
    if (itemsNumber == 2) {
      intensities.add(AppLocalizations.of(context)!.low);
      intensities.add(AppLocalizations.of(context)!.high);
    }
    if (itemsNumber == 3) {
      intensities.add(AppLocalizations.of(context)!.low);
      intensities.add(AppLocalizations.of(context)!.medium);
      intensities.add(AppLocalizations.of(context)!.high);
    }
    return intensities;
  }

  @override
  void dispose() {
    _durationTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportInfo = widget.sport;
      _sportIntensities = NutritionUtils.findSportIntensities(names: widget.allSportsInfo, id: sportInfo.id);
      _sportName = NutritionUtils.findSportName(names: widget.allSportsInfo, ingredients: [sportInfo], context: context);
    // if (widget.sport.minutes != null && _durationTextController.text == '') {
      _duration = widget.sport.minutes;
      _durationTextController.text = !_duration.isNull() ? _duration.toString() : '';
    // }

    if (widget.sport.intensity != null) _intensity = widget.sport.intensity;
    _error = widget.sport.minutes == null || widget.sport.intensity == null;
    final showError = widget.showValidation && _error;

    return Column(
      children: [
      Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.border15),
        color: AppColors.white85Percent,),
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall,),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _sportName.orEmpty(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                ),
              ),
              // InkWell(onTap: () { /*assets/images/favorite_icon.png*/ }, child: Image.asset('assets/icon/un_favorite_outlined.png', height: Dimens.heightXSmall)),
              const SizedBox(width: Dimens.width12),
              InkWell(onTap: () => widget.removeSport.call(), child: const Icon(Icons.cancel_outlined, size: Dimens.height27, color: AppColors.yellowishGreen)),
            ],
          ),
          Text(AppLocalizations.of(context)!.duration, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal)),
          const SizedBox(height: Dimens.height12),
          SizedBox(
            height: Dimens.height34,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _durationTextController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.silver, width: 1), borderRadius: BorderRadius.all(Radius.circular(Dimens.border11))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.silver, width: 1), borderRadius: BorderRadius.all(Radius.circular(Dimens.border11))),
                    ),
                    onChanged: (minutes) {
                      sportInfo.minutes = minutes.isEmpty ? null : int.parse(minutes);
                      widget.editMinutes.call(sportInfo);
                    },
                  ),
                ),
                const SizedBox(width: Dimens.width12),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(Dimens.border11)),
                        border: Border.fromBorderSide(BorderSide(color: AppColors.silver, width: 1))),
                    child: Text(AppLocalizations.of(context)!.minutes.toLowerCase(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimens.height12),
          if (_sportIntensities != null && _sportIntensities! > 1) Text(AppLocalizations.of(context)!.intensity, style: const TextStyle(color: AppColors.yellowishGreen, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w700)),
          if (_sportIntensities != null && _sportIntensities! > 1) Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                height: Dimens.heightSmall - 15,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.all(Radius.circular(11)),
                    border: Border.fromBorderSide(
                        BorderSide(color: AppColors.silver, width: 1))),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: Container(),
                  alignment: Alignment.center,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
                  value: _intensity.isNull() ? null : getIntensityList(_sportIntensities!, context)[_intensity!],
                  onChanged: (String? intensity) {
                    final intensityIndex = getIntensityList(_sportIntensities!, context,).indexOf(intensity ?? '');
                    sportInfo.intensity = intensityIndex;
                    widget.editIntensity.call(sportInfo);
                  },
                  items: getIntensityList(_sportIntensities!, context,)
                      .map<DropdownMenuItem<String>>(
                        (item) => DropdownMenuItem(
                      value: item,
                          alignment: Alignment.center,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeNormal,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
        ],
      ),
    ),
    if (showError) Padding(
      padding: const EdgeInsets.only(top: Dimens.marginXSmall, left: Dimens.paddingSmall),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.please_complete_required_fields,
          style: const TextStyle(color: AppColors.errorRed, fontSize: Dimens.fontSizeSmall),
        ),
      ),
    ),
    ],
    );
  }
}