import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/centered_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/simple_text_field_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_value_icon_box.dart';

import '../../widgets/text_field_general_quest.dart';

class GeneralQuestionsScreen extends StatefulWidget {
  static const routeName = '/general_questions';

  const GeneralQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GeneralQuestionsScreenState();
}

class _GeneralQuestionsScreenState extends State<GeneralQuestionsScreen> {
  final _commonNameController = TextEditingController();

  @override
  void dispose() {
    _commonNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    if (_commonNameController.text == '')
      _commonNameController.text = bloc.state.profile!.commonName ?? '';

    return SafeArea(
      child: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          body: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
            },
            builder: (BuildContext ctx, ProfileState state) {
              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: Dimens.marginXLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          height: 59,
                          width: 59,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: Text(
                          AppLocalizations.of(context)!.body_measurements,
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeXXLarge,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimens.marginNormal,
                            vertical: Dimens.marginSmall),
                        child: TextField(
                          controller: _commonNameController,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(ctx)!.write_your_name_here,
                          ),
                          onChanged: (name) => bloc
                              .add(RefreshCommonNameAction(commonName: name)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimens.marginNormal),
                            child: Text(
                                AppLocalizations.of(ctx)!.birthday_question +
                                    ':'),
                          ),
                          Container(
                            child: state.profile!.birthDate != null
                                ? Text(
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            state.profile!.birthDate!)),
                                    overflow: TextOverflow.fade,
                                  )
                                : const Text(''),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month,
                                color: Colors.grey),
                            onPressed: () {
                              DatePickerHelper.presentDatePicker(
                                context: ctx,
                                saveDate: (DateTime pickedDate) {
                                  bloc.add(RefreshBirthdateAction(
                                      birthdate:
                                          pickedDate.millisecondsSinceEpoch));
                                },
                              );
                            },
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: Dimens.marginLarge),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: Dimens.marginNormal,
                                  right: Dimens.marginXSmall,
                                ),
                                child: CenteredIconBox(
                                  colorSelected: Colors.amber,
                                  icon: Icons.male,
                                  onClick: () =>
                                      bloc.add(SetSexAction(sex: SexType.male)),
                                  isSelected:
                                      state.profile!.sex == SexType.male,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  right: Dimens.marginNormal,
                                  left: Dimens.marginXSmall,
                                ),
                                child: CenteredIconBox(
                                  colorSelected: Colors.amber,
                                  icon: Icons.female,
                                  onClick: () => bloc
                                      .add(SetSexAction(sex: SexType.female)),
                                  isSelected:
                                      state.profile!.sex == SexType.female,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.profile!.sex == SexType.female)
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.fromLTRB(
                                Dimens.marginNormal,
                                Dimens.marginXLarge,
                                Dimens.marginLarge,
                                Dimens.zero,
                              ),
                              child: Text(AppLocalizations.of(context)!
                                  .regularity_period_question),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: Dimens.marginNormal,
                                        right: Dimens.marginSmall),
                                    child: CustomButton1(
                                      message:
                                          AppLocalizations.of(context)!.regular,
                                      isSelected: state
                                              .profile!
                                              .femaleCharacteristics!
                                              .menstruation!
                                              .regularity ==
                                          MenstruationRegularity.regular.index,
                                      action: () {
                                        bloc.add(SetPeriodRegularityAction(
                                            periodRegularity:
                                                MenstruationRegularity
                                                    .regular.index));
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: Dimens.marginNormal,
                                        left: Dimens.marginSmall),
                                    child: CustomButton1(
                                      message: AppLocalizations.of(context)!
                                          .irregular,
                                      isSelected: state
                                              .profile!
                                              .femaleCharacteristics!
                                              .menstruation!
                                              .regularity ==
                                          MenstruationRegularity
                                              .irregular.index,
                                      action: () {
                                        bloc.add(SetPeriodRegularityAction(
                                            periodRegularity:
                                                MenstruationRegularity
                                                    .irregular.index));
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            state.profile!.femaleCharacteristics!.menstruation!
                                        .regularity ==
                                    MenstruationRegularity.regular.index
                                ? Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.fromLTRB(
                                          Dimens.marginNormal,
                                          Dimens.marginXLarge,
                                          Dimens.marginLarge,
                                          Dimens.zero,
                                        ),
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .period_duration_question),
                                      ),
                                      NumberPicker(
                                        minValue: Constants.MIN_PERIOD_DURATION,
                                        maxValue: Constants.MAX_PERIOD_DURATION,
                                        value: state
                                                .profile!
                                                .femaleCharacteristics!
                                                .menstruation!
                                                .daysOfCycle ??
                                            Constants
                                                .PERIOD_DURATION_INITIAL_VALUE,
                                        axis: Axis.horizontal,
                                        step: 1,
                                        textStyle: const TextStyle(
                                          fontSize: Dimens.fontSizeNormal,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color: Colors.blueGrey),
                                        ),
                                        onChanged: (duration) =>
                                            context.read<ProfileBloc>().add(
                                                  SetPeriodDurationAction(
                                                      days: duration),
                                                ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.fromLTRB(
                                          Dimens.marginNormal,
                                          Dimens.marginXLarge,
                                          Dimens.marginSmall,
                                          Dimens.zero,
                                        ),
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .last_period_question),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                left: Dimens.marginLarge),
                                            child: IconButton(
                                              onPressed: () => DatePickerHelper
                                                  .presentDatePicker(
                                                context: context,
                                                saveDate: (pickedDate) => context
                                                    .read<ProfileBloc>()
                                                    .add(
                                                        SetLastPeriodDateAction(
                                                            date: pickedDate)),
                                              ),
                                              icon: const Icon(
                                                  Icons.calendar_month),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                left: Dimens.marginNormal),
                                            child: Text(
                                              state
                                                          .profile!
                                                          .femaleCharacteristics!
                                                          .menstruation!
                                                          .lastStartDate !=
                                                      null
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(
                                                      DateTime.fromMillisecondsSinceEpoch(
                                                          state
                                                              .profile!
                                                              .femaleCharacteristics!
                                                              .menstruation!
                                                              .lastStartDate!),
                                                    )
                                                  : '',
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : Container(),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: Dimens.marginXLarge),
                            )
                          ],
                        ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: Dimens.marginLarge,
                          right: Dimens.marginNormal,
                          left: Dimens.marginNormal,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFieldGeneralQuest(
                                    value: state.profile!
                                        .physicalCharacteristics!.height,
                                    title: AppLocalizations.of(ctx)!.height,
                                    onChanged: (height) {
                                      bloc.add(
                                        SetBodyParameterAction(
                                          parameter: height,
                                          type: BodyParameters.height,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFieldGeneralQuest(
                                    value: state.profile!
                                        .physicalCharacteristics!.weight,
                                    title: AppLocalizations.of(ctx)!.weight,
                                    onChanged: (weight) {
                                      bloc.add(
                                        SetBodyParameterAction(
                                          parameter: weight,
                                          type: BodyParameters.weight,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFieldGeneralQuest(
                                    value: state.profile!
                                        .physicalCharacteristics!.bodyFat,
                                    title: AppLocalizations.of(ctx)!.body_fat,
                                    onChanged: (bodyFat) {
                                      bloc.add(
                                        SetBodyParameterAction(
                                          parameter: bodyFat,
                                          type: BodyParameters.bodyFat,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFieldGeneralQuest(
                                    value: state
                                        .profile!
                                        .physicalCharacteristics!
                                        .waistMeasurement,
                                    title: AppLocalizations.of(ctx)!.waist,
                                    onChanged: (bodyFat) {
                                      bloc.add(
                                        SetBodyParameterAction(
                                          parameter: bodyFat,
                                          type: BodyParameters.waist,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  top: Dimens.marginXLarge),
                              child: RoundedCustomButton(
                                onPressed: () => Navigator.pop(context),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
