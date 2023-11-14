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
  final Function(SportInfo, String) editIntensity;
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
      _sportName = widget.sport.name_en;
    // }
    if (widget.sport.minutes != null && _durationTextController.text == '') {
      _duration = widget.sport.minutes;
      _durationTextController.text = _duration.toString();
    }
    if (widget.sport.timeStart != null) _timeOfDay = DateFormat('hh:mm a, MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(widget.sport.timeStart ?? 0));
    if (widget.sport.intensity != null) _intensity = widget.sport.intensity;
    _error = widget.sport.minutes == null || widget.sport.intensity == null || widget.sport.timeStart == null;

    return SizedBox(
      child: Container(
          margin: const EdgeInsets.fromLTRB(
            Dimens.marginNormal,
            Dimens.zero,
            Dimens.marginNormal,
            Dimens.marginLarge,
          ),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)), side: BorderSide(color: _error ? AppColors.errorRed : AppColors.cardGreen_200, width: 2,style: BorderStyle.solid)),
                color: Colors.green[200],
                child: Container(
                  margin: const EdgeInsets.only(
                    left: Dimens.marginSmall,
                    top: Dimens.marginSmall,
                    right: Dimens.marginSmall,
                    bottom: Dimens.marginNormal,
                  ),
                  child: Column(
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.removeSport.call(),
                            icon: const Icon(Icons.clear),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimens.marginNormal,
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.duration),
                          ),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _durationTextController,
                              onChanged: (minutes) {
                                // setState(() {
                                //   _duration = int.parse(minutes);
                                // });
                                widget.editMinutes.call(SportInfo(id: widget.sport.id, name_es: widget.sport.name_es, name_en: widget.sport.name_en, intensity: widget.sport.intensity, minutes: minutes.isEmpty ? null : int.parse(minutes), timeStart: widget.sport.timeStart));
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                right: Dimens.marginNormal,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.minutes.toLowerCase(),
                            ),
                          )
                        ],
                      ),
                      _sportIntensities != null && _sportIntensities! > 1
                          ? Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                  child: Text(AppLocalizations.of(context)!.intensity),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      ...getIntensityList(_sportIntensities!, context,).map((intensityName) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: Dimens.marginNormal,
                                            right: Dimens.marginNormal,
                                            top: Dimens.marginNormal,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            border: Border.all(
                                              color: _intensity == getIntensityList(_sportIntensities!, context,).indexOf(intensityName) ? Colors.white : Colors.transparent ,
                                              width: 3,
                                            ),
                                          ),
                                          child: InkWell(
                                            child: Text(
                                              intensityName,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            onTap: () {
                                              final intensityIndex = getIntensityList(_sportIntensities!, context,).indexOf(intensityName);
                                              // setState(() {
                                              //   _intensity = intensityIndex;
                                              // });
                                              widget.editIntensity.call(SportInfo(id: widget.sport.id, name_es: widget.sport.name_es, name_en: widget.sport.name_en, intensity: intensityIndex, minutes: widget.sport.minutes, timeStart: widget.sport.timeStart), currentLanguage);
                                            },
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Container(),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                            child: Text('${AppLocalizations.of(context)!.sport_time_start} '),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                            child: Text(_timeOfDay != null ? _timeOfDay.toString() : ''),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () async {
                                final selectedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2024));
                                if (selectedDate != null) {
                                  final selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                  if (selectedTime != null) {
                                    DateTime dateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                                    widget.editDateTime.call(SportInfo(id: widget.sport.id, name_es: widget.sport.name_es, name_en: widget.sport.name_en, intensity: widget.sport.intensity, minutes: widget.sport.minutes, timeStart: dateTime.millisecondsSinceEpoch));
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_error) Container(margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),child: Text(AppLocalizations.of(context)!.must_complete_field, style: TextStyle(color: Colors.red,)),alignment: Alignment.centerLeft,)
            ],
          ),
      ),
    );
  }
}