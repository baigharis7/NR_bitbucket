import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/height_weight_units.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/centered_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
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
    _dropdownList = _heightWeightTypeList.map((e) => e.translate(context)).toList();
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
    String language = Localizations.localeOf(context).languageCode;

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ProfileBloc, ProfileState>(
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
          return Stack(children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'), // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: AppColors.black59Percent, // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimens.padding20),
                child: Stack(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: double.infinity),
                            Container(alignment: AlignmentDirectional.centerStart, child: IconButton(onPressed: () => Navigator.pop(context, Constants.BACK), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,))),
                            Image.asset(
                              'assets/images/logo_name_white.png',
                              width: Dimens.width242,
                            ),
                            const SizedBox(height: Dimens.height37),
                            Text(
                              AppLocalizations.of(context)!.body_measurements,
                              style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge,),
                            ),
                            const SizedBox(height: Dimens.heightSmall),
                            TextFormField(
                              controller: _commonNameController,
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                                hintText:
                                AppLocalizations.of(ctx)!.write_your_name_here,
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                errorMaxLines: 2,
                              ),
                              validator: (value) {
                                return value.isEmptyOrNull() ? AppLocalizations.of(context)!.must_complete_field : null;
                              },
                              // onChanged: (name) => bloc
                              //     .add(RefreshCommonNameAction(commonName: name)),
                              onChanged: (value) {
                                _formKey.currentState!.validate();
                                bloc.add(RefreshCommonNameAction(commonName: value));
                              },
                            ),
                            const SizedBox(height: Dimens.height12),
                            TextFormField(
                              readOnly: true,
                              keyboardType: TextInputType.none,
                              controller: _dateController,
                              onTap: () {
                                showDatePicker(context: context,
                                    initialDate: DateTime(DateTime.now().year-19),
                                    firstDate: DateTime(DateTime.now().year-100),
                                    lastDate: DateTime(DateTime.now().year-19)).then((pickedDate) {
                                  _formKey.currentState!.validate();
                                  if (pickedDate != null) bloc.add(RefreshBirthdateAction(birthdate: pickedDate.millisecondsSinceEpoch));
                                });
                              },
                              style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                              // contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                hintText: state.profile!.birthDate == null ? AppLocalizations.of(ctx)!.birthday_question : DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(state.profile!.birthDate!)),
                                prefixIcon: const Icon(Icons.calendar_month, color: Colors.white),
                              ),
                              validator: (value) => state.profile?.birthDate?.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,),
                            const SizedBox(height: Dimens.height32),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.profile?.sex?.isNull() ?? true) Text(AppLocalizations.of(context)!.select_gender, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17,),),
                                if (state.profile?.sex?.isNull() ?? true) const SizedBox(height: Dimens.height32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CenteredIconBox(
                                        colorSelected: AppColors.yellowishGreen,
                                        icon: Icons.male,
                                        onClick: () =>
                                            bloc.add(SetSexAction(sex: SexType.male)),
                                        isSelected:
                                        state.profile!.sex == SexType.male,
                                      ),
                                    ),
                                    const SizedBox(width: Dimens.width25),
                                    Expanded(
                                      child: CenteredIconBox(
                                        colorSelected: AppColors.yellowishGreen,
                                        icon: Icons.female,
                                        onClick: () => bloc
                                            .add(SetSexAction(sex: SexType.female)),
                                        isSelected:
                                        state.profile!.sex == SexType.female,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (state.profile!.sex == SexType.female)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: Dimens.height32),
                                  Text(AppLocalizations.of(context)!.regularity_period_question, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17,)),
                                  const SizedBox(height: Dimens.height12),
                                  if (state.profile?.femaleCharacteristics?.menstruation?.regularity.isNull() ?? true) Text(AppLocalizations.of(context)!.must_complete_field+':', style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17,), textAlign: TextAlign.start),
                                  const SizedBox(height: Dimens.heightXXSmall),
                                  Row(
                                    children: [
                                      Expanded(flex: 1,
                                          child: GeneralButton(
                                        title: AppLocalizations.of(context)!.regular,
                                            selectedColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.regular.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                            textColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.regular.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                            onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.regular.index)),
                                      ),),
                                      const SizedBox(width: Dimens.width25,),
                                      Expanded(flex: 1,
                                          child: GeneralButton(
                                            title: AppLocalizations.of(context)!.irregular,
                                            selectedColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                            textColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                            onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.irregular.index)),
                                          ),),
                                    ],
                                  ),
                                  const SizedBox(height: Dimens.heightXSmall),
                                  Row(
                                    children: [
                                      Expanded(flex: 1,
                                        child: GeneralButton(
                                          title: AppLocalizations.of(context)!.menopause,
                                          selectedColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.menopause.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                          textColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.menopause.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                          onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.menopause.index)),
                                        ),),
                                      const SizedBox(width: Dimens.width25,),
                                      Expanded(flex: 1,
                                        child: GeneralButton(
                                          title: AppLocalizations.of(context)!.without_period,
                                          selectedColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.withoutPeriod.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                          textColor: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.withoutPeriod.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                          onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.withoutPeriod.index)),
                                        ),),
                                    ],
                                  ),
                                  state.profile!.femaleCharacteristics!.menstruation!
                                      .regularity ==
                                      MenstruationRegularity.regular.index
                                      ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: Dimens.height32,),
                                      Text(AppLocalizations.of(context)!.period_duration_question, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17,),),
                                      const SizedBox(height: Dimens.height12),
                                      Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        child: NumberPicker(
                                          minValue: Constants.MIN_PERIOD_DURATION,
                                          maxValue: Constants.MAX_PERIOD_DURATION,
                                          value: state.profile!.femaleCharacteristics!.menstruation!.daysOfCycle ?? Constants.PERIOD_DURATION_INITIAL_VALUE,
                                          axis: Axis.horizontal,
                                          step: 1,
                                          textStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                                          selectedTextStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            border: Border.all(color: Colors.white),
                                          ),
                                          onChanged: (duration) => context.read<ProfileBloc>().add(SetPeriodDurationAction(days: duration),),
                                        ),
                                      ),
                                      const SizedBox(height: Dimens.height12),
                                      Text(AppLocalizations.of(context)!.last_period_question, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),),
                                      TextFormField(
                                        onTap: () {
                                          DatePickerHelper
                                              .presentDatePicker(
                                            context: context,
                                            saveDate: (pickedDate) {
                                              context.read<ProfileBloc>().add(SetLastPeriodDateAction(date: pickedDate,),);
                                            },
                                          );
                                        },
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: state.profile!.femaleCharacteristics!.menstruation!.lastStartDate != null ? DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(state.profile!.femaleCharacteristics!.menstruation!.lastStartDate!,),) : '',
                                          // border: InputBorder.none,
                                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                          hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal,),
                                          prefixIcon: const Icon(Icons.calendar_month, color: Colors.white),
                                          errorMaxLines: 2,
                                        ),
                                        validator: (value) => state.profile!.femaleCharacteristics?.menstruation?.lastStartDate.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                            const SizedBox(height: Dimens.height32),
                            Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border11),),
                                  color: AppColors.floralWhite,
                                  child: Container(
                                    height: Dimens.heightSmall - 20,
                                    padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall -4, horizontal: Dimens.paddingSmall -2),
                                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginNormal),
                                    child: DropdownButton<int>(
                                      isExpanded: true,
                                      value: state.unitWeightHeight?.id ?? 1,
                                      style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: Colors.black),
                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
                                      underline: Container(),
                                      onChanged: (int? value) {
                                        bloc.add(SetUnitWeightHeight(unitWeightHeight: _heightWeightTypeList.firstWhere((element) => element.id == value,)));
                                      },
                                      dropdownColor: AppColors.floralWhite,
                                      items: _heightWeightTypeList.map<DropdownMenuItem<int>>((HeightWeightUnits value) {
                                        final val = language == 'es' ? value.unitEs.orEmpty() : value.unitEn.orEmpty();
                                        return DropdownMenuItem<int>(
                                          value: value.id,
                                          child: Text(val, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: Colors.black),),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimens.height32),
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
                                    const SizedBox(width: Dimens.width32),
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
                                const SizedBox(height: Dimens.height12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldGeneralQuest(
                                        errorBorderColor: Colors.grey.shade100,
                                        isNumeric: true,
                                        value: state.profile?.physicalCharacteristics?.bodyFat?.toDouble(),
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
                                    const SizedBox(width: Dimens.width32),
                                    Expanded(
                                      child: TextFieldGeneralQuest(
                                        errorBorderColor: Colors.grey.shade100,
                                        isNumeric: true,
                                        value: state.profile?.physicalCharacteristics?.waistMeasurement?.toDouble(),
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
                                const SizedBox(height: Dimens.height32),
                                GeneralButton(
                                  title: AppLocalizations.of(context)!.save,
                                  onTap: () {
                                    if (_formKey.currentState!.validate() && ((state.profile?.physicalCharacteristics?.height ?? 0) > 0) && ((state.profile?.physicalCharacteristics?.weight ?? 0) > 0)) {
                                      bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName)));
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),]
                ),
              ),),
            )
          ],);
        },
      ),
    );
  }
}
