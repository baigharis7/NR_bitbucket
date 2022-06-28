import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:provider/provider.dart';

class WomenSpecificQuestionsModal extends StatelessWidget {
  const WomenSpecificQuestionsModal({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final registryProvider = Provider.of<RegistryProvider>(context, listen: false);

    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(
                    Dimens.marginNormal, Dimens.marginXLarge,
                    Dimens.marginLarge, Dimens.zero),
                child: Text(AppLocalizations.of(context)!.regularity_period_question)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        right: Dimens.marginNormal),
                    child: CustomButton1(
                      message: AppLocalizations.of(context)!.regular,
                      isPushed: registryProvider.getPeriodRegularity == MenstruationRegularity.regular ? true : false,
                      action: () {
                        setState(() {
                          registryProvider.setPeriodRegularity(MenstruationRegularity.regular);
                        });
                      },
                    )
                ),
                Container(
                  margin: const EdgeInsets.only(right: Dimens.marginNormal),
                  child: CustomButton1(
                    message: AppLocalizations.of(context)!.irregular,
                    isPushed: registryProvider.getPeriodRegularity == MenstruationRegularity.irregular ? true : false,
                    action: () {
                      setState(() {
                        registryProvider.setPeriodRegularity(MenstruationRegularity.irregular);
                      });
                    },
                  ),
                )
              ],
            ),
            registryProvider.getPeriodRegularity == MenstruationRegularity.regular
                ? Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(
                            Dimens.marginNormal, Dimens.marginXLarge,
                            Dimens.marginLarge, Dimens.zero),
                        child: Text(AppLocalizations.of(context)!.period_duration_question)
                      ),
                    NumberPicker(
                        minValue: Constants.MIN_PERIOD_DURATION,
                        maxValue: Constants.MAX_PERIOD_DURATION,
                        value: registryProvider.getPeriodDuration,
                        axis: Axis.horizontal,
                        step: 1,
                        textStyle: const TextStyle(
                            fontSize: Dimens.fontSizeNormal
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blueGrey),
                        ),
                        onChanged: (duration) {
                          setState(() {
                            registryProvider.setPeriodDuration(duration);
                          });
                        }
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(
                            Dimens.marginNormal, Dimens.marginXLarge,
                            Dimens.marginLarge, Dimens.zero),
                        child: Text(AppLocalizations.of(context)!.last_period_question)
                    ),
                    registryProvider.getLastPeriodDate == null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(left: Dimens.marginLarge),

                            child: TextButton(
                              onPressed: () =>
                                  DatePickerHelper.presentDatePicker(context: context, saveDate: (pickedDate) => registryProvider.setLastPeriodDate(pickedDate)),
                              child: Text(AppLocalizations.of(context)!.choose_last_period_date),
                            ),
                          )
                        : Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(left: Dimens.marginLarge),
                            child: Text(DateFormat('dd/MM/yyyy').format(registryProvider.getLastPeriodDate!),),
                        ),
                  ],
                )
                : Container(),
            Container(
              margin: const EdgeInsets.only(bottom: Dimens.marginXLarge),
            )
          ],
        ),
      );
    });
  }

}