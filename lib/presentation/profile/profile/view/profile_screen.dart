import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/health_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/profile_info_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/swith_with_function_widget.dart';


import '../../../../data/api/profile/model/upload_user_profile.dart';
import '../../../settings/view/settings_screen.dart';
import '../../../widgets/screen_top_bar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreen();

}

class _ProfileScreen extends State<ProfileScreen> {

  void _showObjectivesBottomModalSheet({required BuildContext context, required Function onSaveChanges}) {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (ctx) => const ObjectivesDialog(),
    ).then((userProfileModel) => onSaveChanges.call());
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(InitializeStateFromProfileAction(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

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
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        },
        builder:  (ctx, state) {
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
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall),
                        child: ScreenTopBar(
                          title: AppLocalizations.of(context)!.profile,
                          onBack: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName, (route) => false);
                            }
                          },
                          trailing: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                            child: const Icon(Icons.settings, size: 28, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge), child: ProfileInfoCard(userProfile: state.profile, onTapProfileUpdate: () => Navigator.pushNamed(context, GeneralQuestionsScreen.routeName).then((value) {if (value.toString() != Constants.BACK) bloc.add(SaveChangesAction());}),)),
                      const SizedBox(height: Dimens.height32),

                      // Combined Temp Needs, Objectives, and Important Info Section
                      Container(
                        padding: const EdgeInsets.all(Dimens.padding20),
                        decoration: const BoxDecoration(
                          color: AppColors.white70Percent,
                        ),
                        child: Column(
                          children: [
                            // Temporary Needs Section
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: - 10,
                              leading: Image.asset('assets/images/hour_glass.png', height: 21, width: 18),
                              title: Text(AppLocalizations.of(context)!.temporary_micronutrients, style: const TextStyle(color: AppColors.redOxide, fontWeight: FontWeight.w900, fontSize: Dimens.fontSize15,),),
                            ),
                            if (state.profile?.sex?.index == SexType.female.index && (state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.menopause.index && state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.withoutPeriod.index)) SwitchDashboardWidget(
                                title: AppLocalizations.of(context)!.menstruation,
                                currentState: state.isMenstruation ?? false,
                                backgroundColor: AppColors.floralWhite,
                                color: AppColors.redOxide,
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                                onStateChange: (value) {
                                  bloc.add(SetMenstruationStateAction(
                                      isMenstruation: value,
                                      onFinish: () {}));
                                }),
                            SwitchDashboardWidget(
                                title: AppLocalizations.of(context)!.cold,
                                currentState: state.isCold ?? false,
                                backgroundColor: AppColors.floralWhite,
                                color: AppColors.redOxide,
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                                onStateChange: (value) {
                                  bloc.add(SetColdStateAction(
                                      isCold: value,
                                      onFinish: () {}));
                                }),
                            InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.other_temp_needs,
                                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal, decoration: TextDecoration.underline, color: AppColors.redOxide,),
                                  ),
                                  const SizedBox(width: Dimens.width5),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.redOxide),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimens.height12),
                            const Divider(color: AppColors.battleshipGrey, height: 1),
                            const SizedBox(height: Dimens.height12),

                            // Objectives Section
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: - 10,
                              leading: Image.asset('assets/images/goal_objectives.png', height: 18, width: 18),
                              title: Text(AppLocalizations.of(context)!.objectives, style: const TextStyle(
                                  color: AppColors.peacockBlue, fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeLarge,),),
                            ),
                            ...?state.filteredObjectives?.map((e) => Container(
                              width: double.infinity,
                                padding: const EdgeInsets.all(Dimens.paddingSmall),
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimens.border50)),
                                child: Text(e.translate(context).toUpperCase(), style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeSmall, color: AppColors.peacockBlue), maxLines: 1, overflow: TextOverflow.ellipsis,))),
                           const SizedBox(height: Dimens.marginNormal),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, ObjectivesProfileScreen.routeName,).then((value) => null),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.update_goals,
                                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal, color: AppColors.peacockBlue, decoration: TextDecoration.underline, decorationColor: AppColors.peacockBlue),
                                  ),
                                  const SizedBox(width: Dimens.width5),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.peacockBlue),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimens.height12),
                            const Divider(color: AppColors.battleshipGrey, height: 1),
                            const SizedBox(height: Dimens.height12),

                            // Important Information Section (moved here)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: - 10,
                              leading: const Icon(Icons.info_outline, size: 21, color: AppColors.yellowishGreen),
                              title: Text(AppLocalizations.of(context)!.imp_info, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w900, fontSize: Dimens.fontSize15,),),
                            ),
                            Column(children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () => Navigator.pushNamed(context, HealthQuestionsScreen.routeName).then((value) { if (value.toString() != Constants.BACK) {
                                  bloc.add(InitializeStateFromProfileAction());
                                } else {
                                  bloc.add(SaveChangesAction());
                                } }),
                                title: Text(AppLocalizations.of(context)!.medical_history, style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.yellowishGreen),
                              ),
                              AnimatedNutrientProgressBarWidget(percent: bloc.getMedicalSituationFillPercentage() * 100, height: Dimens.height5, color: Colors.white, backgroundColor: AppColors.yellowishGreen50),
                            ],),
                            Column(children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () => Navigator.pushNamed(context, DietQuestionsScreen.routeName).then((value) { if (value.toString() != Constants.BACK) bloc.add(SaveChangesAction()); }),
                                title: Text(AppLocalizations.of(context)!.diet, style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.yellowishGreen),
                              ),
                              AnimatedNutrientProgressBarWidget(percent: bloc.getDietPercentageFill() * 100, height: Dimens.height5, color: Colors.white, backgroundColor: AppColors.yellowishGreen50),
                            ],),
                            Column(children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () => Navigator.pushNamed(context, PhysicalActivityScreen.routeName).then((value) {
                                  if (value.toString() != Constants.BACK) bloc.add(SaveChangesAction());
                                }),
                                title: Text(AppLocalizations.of(context)!.physical_activity, style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.yellowishGreen),
                              ),
                              AnimatedNutrientProgressBarWidget(percent: bloc.getPhysicalCharacteristicsFillPercentage() * 100, height: Dimens.height5, color: Colors.white, backgroundColor: AppColors.yellowishGreen50),
                            ],),
                          ],
                        ),
                      ),

                      // ProfileOptionWithGraphicAndAdd(
                      //   title: AppLocalizations.of(context)!.objectives,
                      //   widget: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(children: [
                      //       ...?state.filteredObjectives?.map((e) => Container(
                      //           padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingNormal),
                      //           margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                      //           decoration: BoxDecoration(color:AppColors.mountainMeadow, borderRadius: BorderRadius.circular(5)),
                      //           child: Text(e.translate(context), style: const TextStyle(color: Colors.white,), maxLines: 1, overflow: TextOverflow.ellipsis,))),
                      //     ],),
                      //   ),
                      //   onAdd: () => _showObjectivesBottomModalSheet(
                      //     context: context,
                      //     onSaveChanges: () => bloc.add(SaveChangesAction()),
                      //   ),
                      // ),
                      // ProfileOptionWithGraphicAndAdd(
                      //   title: AppLocalizations.of(context)!.body_measurements,
                      //   widget: FillHorizontalBar(
                      //     fillColor: Colors.white,
                      //     backgroundBarColor: AppColors.yellowishGreen50,
                      //     applyBoxShadow: true,
                      //     fractionToFill: bloc.getPhysicalCharacteristicsFillPercentage(),
                      //     height: 9,
                      //   ),
                      //   onAdd: () => Navigator.pushNamed(context, GeneralQuestionsScreen.routeName).then((value) {
                      //     if (value.toString() != Constants.BACK) bloc.add(SaveChangesAction());
                      //   }),
                      // ),
                      // ProfileOptionWithGraphicAndAdd(
                      //   title: AppLocalizations.of(context)!.medical_history,
                      //   widget: FillHorizontalBar(
                      //     fractionToFill: bloc.getMedicalSituationFillPercentage(),
                      //     height: 9,
                      //   ),
                      //   onAdd: () => Navigator.pushNamed(context, HealthQuestionsScreen.routeName).then((value) => bloc.add(SaveChangesAction())),
                      // ),
                      // ProfileOptionWithGraphicAndAdd(
                      //   title: AppLocalizations.of(context)!.diet,
                      //   widget: FillHorizontalBar(
                      //     fractionToFill: bloc.getDietPercentageFill(),
                      //     height: 9,
                      //   ),
                      //   onAdd: () => Navigator.pushNamed(context, DietQuestionsScreen.routeName).then((value) => bloc.add(SaveChangesAction())),
                      // ),
                      // ProfileOptionWithGraphicAndAdd(
                      //   title: AppLocalizations.of(context)!.physical_activity,
                      //   widget: FillHorizontalBar(
                      //     fractionToFill: bloc.getPhysicalCharacteristicsFillPercentage(),
                      //     height: 9,
                      //   ),
                      //   onAdd: () => Navigator.pushNamed(context, PhysicalActivityScreen.routeName).then((value) {
                      //     if (value.toString() != Constants.BACK) bloc.add(SaveChangesAction());
                      //   }),
                      // ),
                    ],
                  ),
                ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
            ),
          ],);
        },
      ),
    );
  }


}