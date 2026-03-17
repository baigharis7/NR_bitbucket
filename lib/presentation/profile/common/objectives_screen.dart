import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/text_radio_button_expansible.dart';
import 'general_questions_screen.dart';

class ObjectivesScreen extends StatefulWidget {
  static const routeName = '/objectives_screen';

  const ObjectivesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  showObjectivesErrorDialog(BuildContext context) {
    // final mediaQuerySize = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (ctx) => Container(
              padding: const EdgeInsets.all(Dimens.paddingLarge),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.red,),
              margin: const EdgeInsets.symmetric(
                  vertical: Dimens.margin6XLarge, horizontal: 75.0,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container()
                      // const Icon(
                      //   Icons.cancel,
                      //   color: Colors.white,
                      //   size: 24.0,
                      // )
                      ,),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.select_objective,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.fontSizeMedium,
                                decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ],
              ),
            ),);
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(InitializeStateFromRegistryAction(context: context));
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
      },
      builder: (ctx, state) {
        return Stack(
          children: [
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

            // Foreground content for the user interaction

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimens.height32),
                      Image.asset(
                        'assets/images/logo_name_white.png',
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: Dimens.height32),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(Dimens.padding4),
                          decoration: BoxDecoration(
                            color: AppColors.floralWhite,
                              borderRadius: BorderRadius.circular(Dimens.border11),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20, vertical: Dimens.padding4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  titleAlignment: ListTileTitleAlignment.top,
                                  leading: Image.asset('assets/images/goal_objectives.png', height: 35, width: 35),
                                    horizontalTitleGap: Dimens.zero,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(AppLocalizations.of(context)!.goals,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeXXLarge, color: AppColors.peacockBlue),
                                    ),
                                ),
                                const SizedBox(height: Dimens.height12),
                                Text(AppLocalizations.of(context)!.metabolic_objectives,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeLarge, color: AppColors.peacockBlue),
                                ),
                                ...state.objectivesInfoMaster!.metabolicObjectives.map((objective) =>
                                    TextCheckboxBox(
                                      title: objective.translate(context),
                                      checkboxValue: state.profile!.objectives.orEmpty().contains(objective.id),
                                      onChangedCheckbox: () => bloc.add(AddObjectiveToListAction(id: objective.id)),
                                      overflow: TextOverflow.clip,
                                    ),
                                ).toList(),
                                const SizedBox(height: Dimens.height32),
                                Text(AppLocalizations.of(context)!.body_composition_objectives,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeLarge, color: AppColors.peacockBlue),
                                ),
                                ...state.objectivesInfoMaster!.bodyCompositionObjectives.map((objective) =>
                                    TextRadioButtonExpansible(
                                      explanation: '',
                                      title: objective.translate(context),
                                      isSelected: state.profile!.objectives.orEmpty().contains(objective.id),
                                      onPressed: () => bloc.add(AddRadioObjectiveToListAction(id: objective.id)),
                                    ),
                                ).toList(),
                                const SizedBox(height: Dimens.height32),
                                Text(AppLocalizations.of(context)!.other_objectives,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeLarge, color: AppColors.peacockBlue),
                                ),
                                ...state.objectivesInfoMaster!.objectives.map((objective) =>
                                    TextCheckboxBox(
                                      title: objective.translate(context),
                                      checkboxValue: state.profile!.objectives.orEmpty().contains(objective.id),
                                      onChangedCheckbox: () => bloc.add(AddObjectiveToListAction(id: objective.id)),
                                      overflow: TextOverflow.clip,
                                    ),
                                ).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.height32),
                      GeneralButton(
                        onTap: () {
                          if (state.profile!.objectives!.isNotEmpty) {
                            // bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, GeneralQuestionsScreen.routeName)));
                            Navigator.popAndPushNamed(
                                context, GeneralQuestionsScreen.routeName,);
                          } else {
                            showObjectivesErrorDialog(context);
                          }
                        },
                      ),
                      const SizedBox(height: Dimens.height32),
                    ],
                  ),
                ),
              ),
              ),
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
            ),
          ],
        );
      },
    ),
    );
  }
}
