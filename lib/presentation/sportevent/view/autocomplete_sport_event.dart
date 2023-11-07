import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../../domain/models/favorites/sport/sport_favorite.dart';

class AutocompleteSportEvent extends StatefulWidget {
  final SportsInfoMaster sportsInfo;
  final Function onSetSportName;
  final Function onSetMinutes;
  final Function onSetIntensity;
  final Function onSetTimeStart;
  final Function? onSetDateStart;
  final String? sportName;
  final int? duration;
  final TimeOfDay? timeStart;
  final int? sportId;
  final DateTime? dateStart;
  final int? intensity;
  final Function resetSportInfo;
  final String? favoriteName;
  final List<SportFavorite>? sportsFavorite;

  const AutocompleteSportEvent({
    Key? key,
    required this.sportsInfo,
    required this.onSetSportName,
    required this.onSetMinutes,
    required this.onSetIntensity,
    required this.onSetTimeStart,
    this.onSetDateStart,
    required this.sportName,
    this.duration,
    this.timeStart,
    this.sportId,
    this.dateStart,
    this.intensity,
    required this.resetSportInfo,
    this.favoriteName,
    this.sportsFavorite,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutocompleteSportEventState();
}

class _AutocompleteSportEventState extends State<AutocompleteSportEvent> {
  String? _sportName;
  int? _sportIntensities;
  int? _duration;
  int? _intensity;
  TimeOfDay? _timeOfDay;
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
    if (widget.sportName != null && widget.sportName != '') {
      _sportIntensities = eventsHelper.getChosenSportIntensities(widget.sportName, widget.sportsInfo, currentLanguage);
      _sportName = widget.sportName;
    }
    if (widget.duration != null && _durationTextController.text == '') {
      _duration = widget.duration;
      _durationTextController.text = _duration.toString();
    }
    if (widget.timeStart != null) _timeOfDay = widget.timeStart;
    if (widget.intensity != null) _intensity = widget.intensity;

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
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal,
                  Dimens.zero,
                  Dimens.marginNormal,
                  Dimens.marginLarge,
                ),
                child: Autocomplete<String>(
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        labelText: AppLocalizations.of(context)!.enter,
                        suffixIcon: IconButton(
                          icon: textEditingController.text != ''
                              ? const Icon(Icons.highlight_remove, color: Colors.black,)
                              : Container(),
                          onPressed: () {
                            widget.resetSportInfo.call();
                            setState(() {
                              textEditingController.text = '';
                            });
                          },
                        ),
                      ),
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (value) {
                        setState(() {
                          textEditingController;
                        });
                      },
                    );
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return widget.sportsInfo.sportsInfoMaster
                        .map((sport) => sport.translate(context))
                        .toList()
                        .where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (sportName) {
                    setState(() {
                      _sportName = sportName;
                    });
                    _sportIntensities = eventsHelper.getChosenSportIntensities(sportName, widget.sportsInfo, currentLanguage);
                    final sportId = eventsHelper.getSportIdByName(sportName, widget.sportsInfo, currentLanguage);
                    widget.onSetSportName.call(sportName, sportId);
                    widget.onSetDateStart?.call();
                  },
                ),
              ),
              _sportName != null ? Card(
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
                          Container(
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
                                setState(() {
                                  _duration = int.parse(minutes);
                                });
                                widget.onSetMinutes.call(_duration);
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
                                              setState(() {
                                                _intensity = intensityIndex;
                                              });
                                              widget.onSetIntensity.call(intensityIndex);
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
                            child: Text(_timeOfDay != null ? _timeOfDay!.format(context) : ''),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () {
                                DatePickerHelper.presentTimePicker(
                                  context: context,
                                  saveDate: (TimeOfDay timeOfDay) {
                                    setState(() {
                                      _timeOfDay = timeOfDay;
                                    });
                                    widget.onSetTimeStart.call(timeOfDay);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ) : Container(child: !(widget.sportsFavorite?.isNotEmpty ?? false) ? Container() : GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: Dimens.marginNormal,
        mainAxisExtent: 55.0,
        childAspectRatio: 3/1,
      ),
      shrinkWrap: true,
      children: [
        ...widget.sportsFavorite?.map((sport) => Card(
          elevation: 3.00,
          shadowColor: Colors.black,
          child: Container(
            decoration: BoxDecoration(
              // color: state.foodName == food.title ? Colors.amber : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () {
                // sport.
              },
              child: Center(
                child: Text(
                  sport.title.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeSmall,
                  ),
                ),
              ),
            ),
          ),
        ),
        ) ?? [],
      ],
    ),),
            ],
          ),
      ),
    );
  }
}