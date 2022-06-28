import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/provider/add_sport_event_provider.dart';
import 'package:provider/provider.dart';


class AutocompleteSportEvent extends StatefulWidget {
  const AutocompleteSportEvent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutocompleteSportEventState();
}

class _AutocompleteSportEventState extends State<AutocompleteSportEvent> {
  final _minutesController = TextEditingController();

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
  Widget build(BuildContext context) {
    final provider = Provider.of<AddSportEventProvider>(context);
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero, Dimens.marginNormal, Dimens.marginLarge),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                Dimens.zero, Dimens.marginNormal, Dimens.marginLarge),
            child: Autocomplete<String>(
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted
                  ) {
                return TextField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.write_here_hint),
                  controller: textEditingController,
                  focusNode: focusNode,
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return provider.getSportNames(currentLanguage).where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (option) {
                provider.setSportName(option, currentLanguage);
              },
            ),
          ),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.chosen_sport),
              Container(
                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                child: Text(
                  provider.getChosenSportName != null
                      ? provider.getSportName()
                      : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.sport_time_start),
              Container(
                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          DatePickerHelper.presentDatePicker(context: context, saveDate: (dateTime) => provider.setDateStart(dateTime));
                        },
                        child: provider.getDateStart == null
                            ? Text(AppLocalizations.of(context)!.sport_date_start)
                            : Text(DateFormat('dd/MM/yyyy').format(provider.getDateStart!))
                    ),
                    TextButton(
                        onPressed: () {
                          DatePickerHelper.presentTimePicker(context: context, saveDate: (timeOfDay) => provider.setTimeStart(timeOfDay));
                        },
                        child: provider.getTimeStart == null
                            ? Text(AppLocalizations.of(context)!.sport_time_start)
                            : Text('${provider.getTimeStart!.hour}:${provider.getTimeStart!.minute}')
                    ),
                  ],
                ),
              )
            ],
          ),
          provider.getChosenSportName != null && provider.getSportIntensities != null && provider.getSportIntensities! > 1
              ? Row(
                  children: [
                    Text(AppLocalizations.of(context)!.intensity),
                    ...getIntensityList(provider.getSportIntensities!, context).map((intensityName) {
                      return Container(
                        margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal),
                        child: InkWell(
                          child: Text(
                            intensityName,
                            style: const TextStyle(
                              color: Colors.purple,
                              decoration: TextDecoration.underline
                            ),
                          ),
                          onTap: () {
                            final intensityIndex = getIntensityList(provider.getSportIntensities!, context).indexOf(intensityName);
                            provider.setIntensity(intensityIndex, currentLanguage);
                          },
                        ),
                      );
                    })
                  ]
                )
              : Container(),
          Row(
            children: [
              Text('${AppLocalizations.of(context)!.duration}: '),
              TextButton(
                  onPressed: () {
                    DatePickerHelper.presentTimePicker(
                        context: context,
                        saveDate: (TimeOfDay timeOfDay) {
                          provider.setMinutes(timeOfDay.hour*60 + timeOfDay.minute);
                        },
                    );
                  },
                  child: Text(
                      provider.getMinutes != null
                          ? provider.getMinutes.toString()
                          : 'Presiona aquí loko'
                  ),
              ),
              Text(AppLocalizations.of(context)!.minutes.toLowerCase())
            ],
          )
        ],
      ),
    );
  }

}