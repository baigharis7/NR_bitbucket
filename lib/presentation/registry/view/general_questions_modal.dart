import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:provider/provider.dart';


class GeneralQuestionsModal extends StatefulWidget {
  const GeneralQuestionsModal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GeneralQuestionState();

}

class _GeneralQuestionState extends State<GeneralQuestionsModal> {
  final _commonNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final registryProvider = Provider.of<RegistryProvider>(context, listen: false);
    _commonNameController.text = registryProvider.getCommonName.orEmpty();

    return SingleChildScrollView(
      child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.marginXLarge,
                  Dimens.marginLarge, Dimens.zero),
              child: Text(AppLocalizations.of(context)!.name_you_want_to_be_called_by),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.zero, Dimens.marginNormal,
                  Dimens.marginLarge),
              child: TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.write_your_name_here),
                controller: _commonNameController,
                onChanged: (name) => registryProvider.setCommonName(name),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.birthday_question),
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.marginXLarge,
                  Dimens.marginLarge, Dimens.zero),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: registryProvider.getBirthDate != null
                  ? Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: Dimens.marginLarge),
                child: Text(DateFormat('dd/MM/yyyy').format(registryProvider
                    .getBirthDate!),
                ),
              )
                  : Container(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () =>
                      DatePickerHelper.presentDatePicker(context, setState, (pickedDate) => registryProvider.setBirthDate(pickedDate)),
                  child: Text(AppLocalizations.of(context)!.birthday_button,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.marginXLarge,
                  Dimens.marginLarge, Dimens.zero),
              child: Text(
                AppLocalizations.of(context)!.sex_question,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        right: Dimens.marginNormal),
                    child: CustomButton1(
                      message: AppLocalizations.of(context)!.masculine,
                      isPushed: registryProvider.getSex == SexType.male ? true : false,
                      action: () {
                        setState(() {
                          registryProvider.setSex(SexType.male);
                        });
                      },
                    )
                ),
                Container(
                  margin: const EdgeInsets.only(right: Dimens.marginNormal),
                  child: CustomButton1(
                    message: AppLocalizations.of(context)!.feminine,
                    isPushed: registryProvider.getSex == SexType.female ? true : false,
                    action: () {
                      setState(() {
                        registryProvider.setSex(SexType.female);
                      });
                    },
                  ),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.marginXLarge,
                  Dimens.marginLarge, Dimens.zero),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.occupation_question),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal, Dimens.zero, Dimens.marginNormal,
                  Dimens.marginLarge),
              child: Column(
                  children: <Widget>[
                    ...registryProvider.listActivityTypes.map((activityType) =>
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    registryProvider.onActivityTypeSelected(activityType.physicalActivityFactor!);
                                  });
                                },
                                child: Container(
                                    margin: const EdgeInsets.all(Dimens.marginSmall),
                                    decoration: BoxDecoration(color: registryProvider.getActivityType == activityType.physicalActivityFactor
                                        ? Colors.amber
                                        : Colors.transparent,
                                        border: Border.all(
                                          width: Dimens.borderNormal,
                                          color: registryProvider.getActivityType == activityType.physicalActivityFactor
                                              ? Colors.amber
                                              : Colors.transparent,
                                        ),
                                        shape: BoxShape.rectangle,
                                        borderRadius: const BorderRadius.all(Radius.circular(20))),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(Dimens.paddingSmall),
                                      child: Text(activityType.typeName.orEmpty()),
                                    ),
                                  ),
                                ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () => ToastHelper().showToast(
                                    text: activityType.explanation.orEmpty(),),
                                  icon: const Icon(
                                      Icons.info,
                                      color: Colors.amber
                                  ),
                                ),
                              )
                            ]
                        ),
                    ).toList(),
                  ]
              ),
            )
          ]
      ),
    );
  }
}
