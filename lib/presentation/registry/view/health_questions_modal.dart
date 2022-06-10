import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:provider/provider.dart';

class HealthQuestionsModal extends StatelessWidget {

  const HealthQuestionsModal({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final registryProvider = Provider.of<RegistryProvider>(context, listen: false);

    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
          child: Column(
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(
                        Dimens.marginNormal, Dimens.marginXLarge,
                        Dimens.marginLarge, Dimens.zero),
                    child: Text(AppLocalizations.of(context)!.common_diseases_question)
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(Dimens.marginLarge, Dimens.marginSmall, Dimens.zero, Dimens.zero),
                  child: Column(
                    children: <Widget>[
                      ...registryProvider.listDiseases.map((disease) =>
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                registryProvider.manageDiseases(disease.id!);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(Dimens.marginSmall),
                              decoration: BoxDecoration(color: registryProvider.getDiseases.contains(disease.id)
                                  ? Colors.amber
                                  : Colors.transparent,
                                  border: Border.all(
                                    width: Dimens.borderNormal,
                                    color: registryProvider.getDiseases.contains(disease.id)
                                        ? Colors.amber
                                        : Colors.transparent,
                                  ),
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.all(Radius.circular(20))),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(Dimens.paddingSmall),
                                child: Text(disease.name.orEmpty()),
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(
                      Dimens.marginNormal, Dimens.marginXLarge,
                      Dimens.marginLarge, Dimens.zero),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.medication_question),
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            registryProvider.setPharmaceuticalTreatment(value!);
                          });
                        },
                        value: registryProvider.isUnderTreatment,),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(AppLocalizations.of(context)!.height_question + ' cm'),
                        NumberPicker(
                          value: registryProvider.getHeight,
                          maxValue: Constants.HEIGHT_MAX,
                          minValue: Constants.HEIGHT_MIN,
                          step: 1,
                          textStyle: const TextStyle(
                              fontSize: Dimens.fontSizeNormal
                          ),
                          axis: Axis.horizontal,
                          onChanged: (height) {
                            setState(() {
                              registryProvider.setHeight(height);
                            });
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                        ),
                      ]
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(AppLocalizations.of(context)!.weight_question + ' kg'),
                        NumberPicker(
                          value: registryProvider.getWeight,
                          maxValue: Constants.WEIGHT_MAX,
                          minValue: Constants.WEIGHT_MIN,
                          step: 1,
                          textStyle: const TextStyle(
                              fontSize: Dimens.fontSizeNormal
                          ),
                          axis: Axis.horizontal,
                          onChanged: (weight) {
                            setState(() {
                              registryProvider.setWeight(weight);
                            });
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                        ),
                      ]
                  ),
                ),
                FittedBox(
                  child: Container(
                    margin: const EdgeInsets.only(left: Dimens.marginXLarge),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(AppLocalizations.of(context)!.body_fat_question + ' %'),
                          NumberPicker(
                            value: registryProvider.getBodyFat,
                            maxValue: Constants.MAX_BODY_FAT,
                            minValue: Constants.MIN_BODY_FAT,
                            step: 1,
                            textStyle: const TextStyle(
                                fontSize: Dimens.fontSizeNormal
                            ),
                            axis: Axis.horizontal,
                            onChanged: (bodyFat) {
                              setState(() {
                                registryProvider.setBodyFat(bodyFat);
                              });
                            },
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.blueGrey),
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(AppLocalizations.of(context)!.waist_measurement_question + ' cm'),
                        NumberPicker(
                          value: registryProvider.getWaistMeasurement,
                          maxValue: Constants.MAX_WAIST_MEASUREMENT,
                          minValue: Constants.MIN_WAIST_MEASUREMENT,
                          step: 1,
                          textStyle: const TextStyle(
                              fontSize: Dimens.fontSizeNormal
                          ),
                          axis: Axis.horizontal,
                          onChanged: (waist) {
                            setState(() {
                              registryProvider.setWaistMeasurement(waist);
                            });
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                        ),
                      ]
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: Dimens.marginXLarge),
                )
              ]
          )
      );
    });
  }
}