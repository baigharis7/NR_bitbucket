import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';

// TODO: think a new name for title and take it from AppLocalizations.
class HealthQuestionsScreen extends StatefulWidget {
  static const routeName = '/health_questions';
  const HealthQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HealthQuestionsScreen();
}

class _HealthQuestionsScreen extends State<HealthQuestionsScreen> {
  late ProfileBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<ProfileBloc>(context);
    super.initState();
  }

  void onBack() {
    bloc.add(InitializeStateFromProfileAction());
    Navigator.pop(context, Constants.BACK);
  }

  @override
  Widget build(BuildContext context) {

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
                        padding: const EdgeInsets.fromLTRB(Dimens.padding20, Dimens.padding20, Dimens.padding20, 0),
                        child: Column(children: [
                          ScreenTopBar(onBack: () => onBack()),
                          const SizedBox(height: Dimens.height12),
                          HeaderAddItemCardSection(title: AppLocalizations.of(context)!.medical_history),
                          const SizedBox(height: Dimens.height12),
                        ]),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                          decoration: BoxDecoration(
                            color: AppColors.white85Percent,
                            borderRadius: BorderRadius.circular(Dimens.border18),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                ...state.commonDiseases.orEmpty().map((commonDisease) {
                                  return TextCheckboxBox(
                                    title: commonDisease.name.orEmpty(),
                                    checkboxValue: state.profile!.medicalSituation!
                                        .commonDiseases!.contains(commonDisease.id),
                                    onChangedCheckbox: () =>
                                        bloc.add(ManageCommonDiseaseAction(commonDiseaseId: commonDisease.id!)),
                                    overflow: TextOverflow.clip,
                                  );
                                }).toList(),
                              ],),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.height12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                        child: GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context),),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
              ),
            ],),
          );
        },
      ),
    );
  }
}