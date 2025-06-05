import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../../domain/models/favorites/sport/sport_favorite.dart';

class SportEventItem extends StatefulWidget {
  final int? sportIntensities;
  final SportInfo sport;
  final Function removeSport;
  final Function(SportInfo) editMinutes;
  final Function(SportInfo) editIntensity;
  final Function(SportInfo) editDateTime;
  const SportEventItem({
    Key? key,
    required this.sportIntensities,
    required this.sport,
    required this.removeSport,
    required this.editMinutes,
    required this.editIntensity,
    required this.editDateTime,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SportEventItem();
}

class _SportEventItem extends State<SportEventItem> {
  String? _sportName;
  int? _sportIntensities;
  int? _duration;
  int? _intensity;
  String? _timeOfDay;
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
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventsHelper = EventsHelper();
    // if (widget.sportName != null && widget.sportName != '') {
      _sportIntensities = widget.sportIntensities;
      _sportName = widget.sport.translate(context);
    // }
    if (widget.sport.minutes != null && _durationTextController.text == '') {
      _duration = widget.sport.minutes;
      _durationTextController.text = _duration.toString();
    }
    if (widget.sport.timeStart != null) _timeOfDay = DateFormat('hh:mm a, MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(widget.sport.timeStart ?? 0));
    if (widget.sport.intensity != null) _intensity = widget.sport.intensity;
    // _error = widget.sport.minutes == null || widget.sport.intensity == null || widget.sport.timeStart == null;
    _error = widget.sport.minutes == null || widget.sport.intensity == null;

    return Container(
      decoration: BoxDecoration(
        border: _error ? const Border.fromBorderSide(BorderSide(color: AppColors.red45Percent,  width: 4)) : null,
        borderRadius: BorderRadius.circular(15),
        color: _error ? AppColors.white65Percent : AppColors.white85Percent,),
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      left: Dimens.marginNormal,
                  ),
                  child: Text(
                    _sportName.orEmpty(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: Dimens.fontSizeLarge,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => widget.removeSport.call(),
                icon: const Icon(Icons.cancel_outlined, size: Dimens.heightXSmall),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: Dimens.marginNormal,
            ),
            child:
            Text(AppLocalizations.of(context)!.duration, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal)),
          ),
          const SizedBox(height: Dimens.height12),
          SizedBox(
            height: Dimens.heightSmall - 15,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _durationTextController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                        borderSide: BorderSide(color: AppColors.silver, width: 1),
                      ),
                    ),
                    onChanged: (minutes) {
                      widget.editMinutes.call(SportInfo(id: widget.sport.id, name_es: widget.sport.name_es, name_en: widget.sport.name_en, intensity: widget.sport.intensity, minutes: minutes.isEmpty ? null : int.parse(minutes), timeStart: widget.sport.timeStart));
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        left: Dimens.marginNormal,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(11)),
                        border: Border.fromBorderSide(
                            BorderSide(color: AppColors.silver, width: 2))),
                    child: Text(
                      AppLocalizations.of(context)!.minutes.toLowerCase(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
            child: Text(AppLocalizations.of(context)!.intensity, style: const TextStyle(color: AppColors.yellowishGreen, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w700)),
          ),
          _sportIntensities != null && _sportIntensities! > 1
              ? Container(
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
                    widget.editIntensity.call(SportInfo(id: widget.sport.id, name_es: widget.sport.name_es, name_en: widget.sport.name_en, intensity: intensityIndex, minutes: widget.sport.minutes, timeStart: widget.sport.timeStart));
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
              )
              : Container(),
        ],
      ),
    );
  }
}