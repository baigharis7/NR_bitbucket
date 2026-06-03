import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/height_weight_units.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_picker_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
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
import 'package:nutrenaissance_flutter/presentation/widgets/onboarding_progress_dots.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/text_field_general_quest.dart';
import 'objectives_screen.dart';

class GeneralQuestionsScreen extends StatefulWidget {
  static const routeName = '/general_questions';

  const GeneralQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GeneralQuestionsScreenState();
}

class _GeneralQuestionsScreenState extends State<GeneralQuestionsScreen> {
  late ProfileBloc bloc;
  final _commonNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _heightWeightTypeList = HeightWeightUnits.getAllUnits();
  late List<String> _dropdownList;

  @override
  void initState() {
    bloc = BlocProvider.of<ProfileBloc>(context);
    _dropdownList = _heightWeightTypeList.map((e) => e.translate(context)).toList();
    super.initState();
  }

  @override
  void dispose() {
    _commonNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void onBack() {
    bloc.add(InitializeStateFromProfileAction());
    Navigator.pop(context, Constants.BACK);
  }

  String? _validateBodyParameter({
    required BuildContext context,
    required String? value,
    required bool isImperial,
    required double metricMin,
    required double metricMax,
    required double imperialMin,
    required double imperialMax,
  }) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.must_complete_field;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return AppLocalizations.of(context)!.must_complete_field;
    }
    final min = isImperial ? imperialMin : metricMin;
    final max = isImperial ? imperialMax : metricMax;
    if (parsed < min || parsed > max) {
      return AppLocalizations.of(context)!.value_out_of_range;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    if (_commonNameController.text == '') _commonNameController.text = bloc.state.profile!.commonName ?? '';
    String language = Localizations.localeOf(context).languageCode;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final isOnboarding = args?['isOnboarding'] == true;
    const inputFg = AppColors.yellowishGreen;

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
          if (state.onError != null) {
            showErrorSnackBar(ctx, resolveError(ctx, state.onError!));
          }
        },
        builder: (BuildContext ctx, ProfileState state) {
          return WillPopScope(
            onWillPop: () {
              onBack();
              return Future.value(true);
            },
            child: Stack(children: [
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0), // Needed to activate the blur
                ),
              ),

              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(child: Column(
                  children: [
                    if (isOnboarding) ...[
                      const SizedBox(height: Dimens.height12),
                      // Invisible spacer matches ScreenTopBar height on
                      // subsequent screens so the logo Y position stays put.
                      const SizedBox(height: 28),
                      const SizedBox(height: Dimens.height12),
                      Image.asset(
                        'assets/images/logo_name_white.png',
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: Dimens.paddingLarge),
                    ] else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding20, Dimens.padding20, Dimens.padding20, 0),
                        child: Column(children: [
                          ScreenTopBar(onBack: () => onBack()),
                          const SizedBox(height: Dimens.height12),
                          HeaderAddItemCardSection(title: AppLocalizations.of(context)!.edit_profile, icon: Icons.person, iconColor: Colors.white),
                          const SizedBox(height: Dimens.height12),
                        ]),
                      ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20, vertical: Dimens.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppColors.floralWhite,
                          borderRadius: BorderRadius.circular(Dimens.border15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isOnboarding) ...[
                              ListTile(
                                titleAlignment: ListTileTitleAlignment.top,
                                leading: const Icon(Icons.person, size: 35, color: AppColors.yellowishGreen),
                                horizontalTitleGap: 6,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  AppLocalizations.of(context)!.profile,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen),
                                ),
                              ),
                              const SizedBox(height: Dimens.height12),
                            ],
                            Expanded(
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                              const SizedBox(width: double.infinity),
                              TextFormField(
                                controller: _commonNameController,
                                cursorColor: inputFg,
                                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                                  hintText:
                                  '${AppLocalizations.of(ctx)!.write_your_name_here} *',
                                  hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                  focusColor: inputFg,
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: inputFg, width: 1)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: inputFg, width: 2)),
                                  errorMaxLines: 2,
                                ),
                                validator: (value) {
                                  return value.isEmptyOrNull() ? AppLocalizations.of(context)!.must_complete_field : null;
                                },
                                onChanged: (value) {
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
                                    if (pickedDate != null) bloc.add(RefreshBirthdateAction(birthdate: pickedDate.millisecondsSinceEpoch));
                                  });
                                },
                                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                decoration: InputDecoration(
                                  errorMaxLines: 2,
                                // contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                                  hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: inputFg, width: 1)),
                                  hintText: state.profile!.birthDate == null ? '${AppLocalizations.of(ctx)!.birthday_question} *' : DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(state.profile!.birthDate!)),
                                  prefixIcon: Icon(Icons.calendar_month, color: inputFg),
                                ),
                                validator: (value) => state.profile?.birthDate?.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,),
                              const SizedBox(height: Dimens.height32),
                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (state.profile?.sex?.isNull() ?? true) Text('${AppLocalizations.of(context)!.select_gender} *', style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17, color: inputFg),),
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
                                    Text(AppLocalizations.of(context)!.regularity_period_question, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17, color: inputFg)),
                                    const SizedBox(height: Dimens.height12),
                                    Row(
                                      children: [
                                        Expanded(flex: 1,
                                            child: GeneralButton(
                                          title: AppLocalizations.of(context)!.regular,
                                              selectedColor: state.profile!.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.regular.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                              textColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.regular.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                              onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.regular.index)),
                                              fontSize: Dimens.fontSize17,
                                        ),),
                                        const SizedBox(width: Dimens.width25,),
                                        Expanded(flex: 1,
                                            child: GeneralButton(
                                              title: AppLocalizations.of(context)!.irregular,
                                              selectedColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.irregular.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                              textColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.irregular.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                              onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.irregular.index)),
                                              fontSize: Dimens.fontSize17,
                                            ),),
                                      ],
                                    ),
                                    const SizedBox(height: Dimens.heightXSmall),
                                    Row(
                                      children: [
                                        Expanded(flex: 1,
                                          child: GeneralButton(
                                            title: AppLocalizations.of(context)!.menopause,
                                            selectedColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.menopause.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                            textColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.menopause.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                            onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.menopause.index)),
                                            fontSize: Dimens.fontSize17,
                                          ),),
                                        const SizedBox(width: Dimens.width25,),
                                        Expanded(flex: 1,
                                          child: GeneralButton(
                                            title: AppLocalizations.of(context)!.without_period,
                                            selectedColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.withoutPeriod.index ? AppColors.yellowishGreen : AppColors.floralWhite,
                                            textColor: state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.withoutPeriod.index ? AppColors.floralWhite : AppColors.yellowishGreen,
                                            onTap: () => bloc.add(SetPeriodRegularityAction(periodRegularity: MenstruationRegularity.withoutPeriod.index)),
                                            fontSize: Dimens.fontSize17,
                                          ),),
                                      ],
                                    ),
                                    const SizedBox(height: Dimens.height12),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () => bloc.add(ClearMenstruationAction()),
                                        child: Text(
                                          AppLocalizations.of(context)!.skip_for_now,
                                          style: AppTextStyles.merriWeather.copyWith(
                                            fontSize: Dimens.fontSize17,
                                            color: inputFg,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    state.profile?.femaleCharacteristics?.menstruation?.regularity == MenstruationRegularity.regular.index
                                        ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: Dimens.height32,),
                                        Text(AppLocalizations.of(context)!.period_duration_question, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17, color: inputFg),),
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
                                            textStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                            selectedTextStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              border: Border.all(color: inputFg),
                                            ),
                                            onChanged: (duration) => context.read<ProfileBloc>().add(SetPeriodDurationAction(days: duration),),
                                          ),
                                        ),
                                        const SizedBox(height: Dimens.height12),
                                        Text('${AppLocalizations.of(context)!.last_period_question} *', style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),),
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
                                            hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeNormal, color: inputFg),
                                            prefixIcon: Icon(Icons.calendar_month, color: inputFg),
                                            errorMaxLines: 2,
                                          ),
                                          validator: (value) => state.profile!.femaleCharacteristics?.menstruation?.lastStartDate.isNull() ?? true ? AppLocalizations.of(context)!.must_complete_field : null,
                                        ),
                                      ],
                                    )
                                        : Container(),
                                  ],
                                ),
                              const SizedBox(height: Dimens.height12),
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
                                          dark: true,
                                          errorBorderColor: Colors.grey.shade100,
                                          isNumeric: true,
                                          integerOnly: true,
                                          value: state.profile!
                                              .physicalCharacteristics!.height,
                                          title: '${state.unitWeightHeight?.height ?? AppLocalizations.of(ctx)!.height} *',
                                          validator: (value) => _validateBodyParameter(
                                            context: context,
                                            value: value,
                                            isImperial: state.profile?.physicalCharacteristics?.unit == 2,
                                            metricMin: 50,
                                            metricMax: 250,
                                            imperialMin: 1.5, // ft
                                            imperialMax: 8.5, // ft
                                          ),
                                          onChanged: (height) {
                                            final parsed = double.tryParse(height);
                                            if (parsed == null) return;
                                            bloc.add(
                                              SetBodyParameterAction(
                                                parameter: parsed,
                                                type: BodyParameters.height,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: Dimens.width32),
                                      Expanded(
                                        child: TextFieldGeneralQuest(
                                          dark: true,
                                          errorBorderColor: Colors.grey.shade100,
                                          isNumeric: true,
                                          integerOnly: true,
                                          value: state.profile!
                                              .physicalCharacteristics!.weight,
                                          title: '${state.unitWeightHeight?.weight ?? AppLocalizations.of(ctx)!.weight} *',
                                          validator: (value) => _validateBodyParameter(
                                            context: context,
                                            value: value,
                                            isImperial: state.profile?.physicalCharacteristics?.unit == 2,
                                            metricMin: 20,
                                            metricMax: 300,
                                            imperialMin: 44, // lb
                                            imperialMax: 660, // lb
                                          ),
                                          onChanged: (weight) {
                                            final parsed = double.tryParse(weight);
                                            if (parsed == null) return;
                                            bloc.add(
                                              SetBodyParameterAction(
                                                parameter: parsed,
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
                                          dark: true,
                                          errorBorderColor: Colors.grey.shade100,
                                          isNumeric: true,
                                          value: state.profile?.physicalCharacteristics?.bodyFat?.toDouble(),
                                          title: AppLocalizations.of(ctx)!.body_fat,
                                          onChanged: (bodyFat) {
                                            final parsed = double.tryParse(bodyFat);
                                            if (parsed == null) return;
                                            bloc.add(
                                              SetBodyParameterAction(
                                                parameter: parsed,
                                                type: BodyParameters.bodyFat,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: Dimens.width32),
                                      Expanded(
                                        child: TextFieldGeneralQuest(
                                          dark: true,
                                          errorBorderColor: Colors.grey.shade100,
                                          isNumeric: true,
                                          value: state.profile?.physicalCharacteristics?.waistMeasurement?.toDouble(),
                                          title: AppLocalizations.of(ctx)!.waist,
                                          onChanged: (waist) {
                                            final parsed = double.tryParse(waist);
                                            if (parsed == null) return;
                                            bloc.add(
                                              SetBodyParameterAction(
                                                parameter: parsed,
                                                type: BodyParameters.waist,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                      ),
                    ),
                    ),
                    ]))),
                    const SizedBox(height: Dimens.height25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                      child: GeneralButton(
                        title: isOnboarding
                            ? AppLocalizations.of(context)!.next
                            : AppLocalizations.of(context)!.save,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            if (isOnboarding) {
                              Navigator.popAndPushNamed(
                                context,
                                ObjectivesScreen.routeName,
                                arguments: const {'isOnboarding': true},
                              );
                            } else {
                              bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName)));
                            }
                          }
                        },
                      ),
                    ),
                    if (isOnboarding)
                      const OnboardingProgressDots(currentStep: 1)
                    else
                      const SizedBox(height: 30),
                  ],
                ),),
                bottomNavigationBar: isOnboarding ? null : const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
              )
            ],),
          );
        },
      ),
    );
  }
}
