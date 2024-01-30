import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/height_weight_units.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/centered_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/simple_text_field_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_value_icon_box.dart';

import '../../../infrastructure/helpers/toast_helper.dart';
import '../../widgets/text_field_general_quest.dart';

class GeneralQuestionsScreen extends StatefulWidget {
  static const routeName = '/general_questions';

  const GeneralQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GeneralQuestionsScreenState();
}

class _GeneralQuestionsScreenState extends State<GeneralQuestionsScreen> {
  final _commonNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _heightWeightTypeList = HeightWeightUnits.getAllUnits();
  late List<String> _dropdownList;

  @override
  void initState() {
    _dropdownList = _heightWeightTypeList.map((e) => e.unit.toString()).toList();
    super.initState();
  }

  @override
  void dispose() {
    _commonNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    if (_commonNameController.text == '') _commonNameController.text = bloc.state.profile!.commonName ?? '';

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
                  child: Form(
                    key: _formKey,
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
                          child: TextFormField(
                            controller: _commonNameController,
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(ctx)!.write_your_name_here,
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              return value.isEmptyOrNull() ? AppLocalizations.of(context)!.must_complete_field : null;
                            },
                            // onChanged: (name) => bloc
                            //     .add(RefreshCommonNameAction(commonName: name)),
                            onChanged: (value) {
                              _formKey.currentState!.validate();
                             /*alue.isEmptyOrNull() ? _formKey.currentState!.validate() : */bloc.add(RefreshCommonNameAction(commonName: value));
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: Dimens.marginNormal,),
                                child: TextFormField(readOnly: true, keyboardType: TextInputType.none, controller: _dateController,
                                    onTap: () {
                                    showDatePicker(context: context,
                                        initialDate: DateTime(DateTime.now().year-19),
                                        firstDate: DateTime(DateTime.now().year-100),
                                        lastDate: DateTime(DateTime.now().year-19)).then((pickedDate) {
                                          _formKey.currentState!.validate();
                                          if (pickedDate != null) bloc.add(RefreshBirthdateAction(birthdate: pickedDate.millisecondsSinceEpoch));
                                        });
                                  // DatePickerHelper.presentDatePicker(
                                  //   context: ctx,
                                  //   saveDate: (DateTime pickedDate) {
                                  //     bloc.add(RefreshBirthdateAction(
                                  //         birthdate:
                                  //         pickedDate.millisecondsSinceEpoch));
                                  //   },
                                  // );
                                }, decoration: InputDecoration(
                                        errorMaxLines: 2,
                                        hintText: state.profile!.birthDate == null ? AppLocalizations.of(ctx)!.birthday_question : DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(state.profile!.birthDate!)),),
                                validator: (value) => state.profile?.birthDate?.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,),
                              ),
                            ),
                            // Container(
                            //   child: state.profile!.birthDate != null
                            //       ? Text(
                            //           DateFormat('dd/MM/yyyy').format(
                            //               DateTime.fromMillisecondsSinceEpoch(
                            //                   state.profile!.birthDate!)),
                            //           overflow: TextOverflow.fade,
                            //         )
                            //       : const Text(''),
                            // ),
                            // IconButton(
                            //   icon: const Icon(Icons.calendar_month,
                            //       color: Colors.grey),
                            //   onPressed: () {
                            //     DatePickerHelper.presentDatePicker(
                            //       context: ctx,
                            //       saveDate: (DateTime pickedDate) {
                            //         bloc.add(RefreshBirthdateAction(
                            //             birthdate:
                            //                 pickedDate.millisecondsSinceEpoch));
                            //       },
                            //     );
                            //   },
                            // )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: Dimens.marginLarge),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.profile?.sex?.isNull() ?? true) Container(margin: const EdgeInsets.only(
                        left: Dimens.marginNormal,
                          right: Dimens.marginXSmall,
                        ),child: Text(AppLocalizations.of(context)!.must_complete_field+':', style: const TextStyle(color: Colors.red,),textAlign: TextAlign.start)),
                              Row(
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
                                        errorBorderColor: (state.profile?.sex?.isNull() ?? true) ? Colors.red : Colors.grey.shade100,
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
                                        errorBorderColor: (state.profile?.sex?.isNull() ?? true) ? Colors.red : Colors.grey.shade100,
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
                              if (state.profile?.femaleCharacteristics?.menstruation?.regularity.isNull() ?? true) Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.symmetric(
                                horizontal: Dimens.marginNormal,
                                vertical: Dimens.marginNormal,
                              ),child: Text(AppLocalizations.of(context)!.must_complete_field+':', style: const TextStyle(color: Colors.red,),textAlign: TextAlign.start)),
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
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              hintText: state.profile!.femaleCharacteristics!.menstruation!.lastStartDate != null ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(state.profile!.femaleCharacteristics!.menstruation!.lastStartDate!,),) : '',
                                              border: InputBorder.none,
                                              prefixIcon: IconButton(onPressed: () {
                                                DatePickerHelper
                                                    .presentDatePicker(
                                                  context: context,
                                                  saveDate: (pickedDate) {
                                                    _formKey.currentState!.validate();
                                                    context.read<ProfileBloc>().add(SetLastPeriodDateAction(date: pickedDate,),);
                                                    },
                                                );
                                              }, icon: const Icon(Icons.calendar_month, color: Colors.black),),
                                              errorMaxLines: 2,
                                            ),
                                            validator: (value) => state.profile!.femaleCharacteristics?.menstruation?.lastStartDate.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,
                                          ),
                                        ),
                                        // Row(
                                        //   children:
                                        //     Container(
                                        //       alignment: Alignment.centerLeft,
                                        //       margin: const EdgeInsets.only(
                                        //           left: Dimens.marginLarge),
                                        //       child: IconButton(
                                        //         onPressed: () => DatePickerHelper
                                        //             .presentDatePicker(
                                        //           context: context,
                                        //           saveDate: (pickedDate) => context
                                        //               .read<ProfileBloc>()
                                        //               .add(
                                        //                   SetLastPeriodDateAction(
                                        //                       date: pickedDate)),
                                        //         ),
                                        //         icon: const Icon(
                                        //             Icons.calendar_month),
                                        //       ),
                                        //     ),
                                        //     Container(
                                        //       alignment: Alignment.centerLeft,
                                        //       margin: const EdgeInsets.only(
                                        //           left: Dimens.marginNormal),
                                        //       child: Text(
                                        //         state
                                        //                     .profile!
                                        //                     .femaleCharacteristics!
                                        //                     .menstruation!
                                        //                     .lastStartDate !=
                                        //                 null
                                        //             ? DateFormat('dd/MM/yyyy')
                                        //                 .format(
                                        //                 DateTime.fromMillisecondsSinceEpoch(
                                        //                     state
                                        //                         .profile!
                                        //                         .femaleCharacteristics!
                                        //                         .menstruation!
                                        //                         .lastStartDate!),
                                        //               )
                                        //             : '',
                                        //       ),
                                        //     ),
                                        //   ],
                                        // )
                                      ],
                                    )
                                  : Container(),
                              Container(
                                margin: const EdgeInsets.only(
                                    bottom: Dimens.marginXLarge,),
                              ),
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
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall, horizontal: Dimens.marginSmall),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12)),
                                child: Container(
                                  height: Dimens.heightSmall - 20,
                                  padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall -4, horizontal: Dimens.paddingSmall -2),
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginNormal),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: state.unitWeightHeight?.unit ?? _dropdownList.first,
                                    // icon: const Icon(Icons.arrow_downward),
                                    // elevation: 16,
                                    // style: const TextStyle(color: Colors.deepPurple),
                                    underline: Container(),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      // setState(() {
                                      //   dropdownValue = value.orEmpty();
                                      // });
                                      
                                      bloc.add(SetUnitWeightHeight(unitWeightHeight: _heightWeightTypeList.firstWhere((element) => element.unit == value,)));
                                    },
                                    items: _dropdownList.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFieldGeneralQuest(
                                      errorBorderColor: (state.profile?.physicalCharacteristics?.height ?? 0) <= 0 ? Colors.red : Colors.grey.shade100,
                                      isNumeric: true,
                                      value: state.profile!
                                          .physicalCharacteristics!.height,
                                      title: state.unitWeightHeight?.height ?? AppLocalizations.of(ctx)!.height,
                                      onChanged: (height) {
                                        bloc.add(
                                          SetBodyParameterAction(
                                            parameter: double.parse(height),
                                            type: BodyParameters.height,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFieldGeneralQuest(
                                      errorBorderColor: (state.profile?.physicalCharacteristics?.weight ?? 0) <= 0 ? Colors.red : Colors.grey.shade100,
                                      isNumeric: true,
                                      value: state.profile!
                                          .physicalCharacteristics!.weight,
                                      title: state.unitWeightHeight?.weight ?? AppLocalizations.of(ctx)!.weight,
                                      onChanged: (weight) {
                                        bloc.add(
                                          SetBodyParameterAction(
                                            parameter: double.parse(weight),
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
                                      errorBorderColor: Colors.grey.shade100,
                                      isNumeric: true,
                                      value: state.profile!
                                          .physicalCharacteristics!.bodyFat!.toDouble(),
                                      title: AppLocalizations.of(ctx)!.body_fat,
                                      onChanged: (bodyFat) {
                                        bloc.add(
                                          SetBodyParameterAction(
                                            parameter: double.parse(bodyFat.toString()),
                                            type: BodyParameters.bodyFat,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFieldGeneralQuest(
                                      errorBorderColor: Colors.grey.shade100,
                                      isNumeric: true,
                                      value: state
                                          .profile!
                                          .physicalCharacteristics!
                                          .waistMeasurement!.toDouble(),
                                      title: AppLocalizations.of(ctx)!.waist,
                                      onChanged: (bodyFat) {
                                        bloc.add(
                                          SetBodyParameterAction(
                                            parameter: double.parse(bodyFat),
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
                                  onPressed: () {
                                    if (_formKey.currentState!.validate() && ((state.profile?.physicalCharacteristics?.height ?? 0) > 0) && ((state.profile?.physicalCharacteristics?.weight ?? 0) > 0)) {
                                      // ToastHelper().showToast(text: 'validate');
                                      bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName)));
                                      // bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, GeneralQuestionsScreen.routeName)));
                                    }
                                    // else {
                                    //   bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName)));
                                    // }
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
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
