import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/aversions_screen.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/screen_top_bar.dart';

class DietQuestionsScreen extends StatefulWidget {
  static const routeName = '/diet_question';
  const DietQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DietQuestionsScreenState();
}

class _DietQuestionsScreenState extends State<DietQuestionsScreen> {
  late ProfileBloc bloc;
  bool _isDietTypeExpanded = false;
  bool _isAllergensExpanded = false;
  bool _isIntolerancesExpanded = false;
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
        builder: (BuildContext ctx, ProfileState state) {
          return WillPopScope(
            onWillPop: () {
              onBack();
              return Future.value(true);
            },
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.black.withOpacity(0),
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
                            HeaderAddItemCardSection(
                              title: AppLocalizations.of(context)!.diet,
                              image: 'assets/images/meal_time_1.png',
                            ),
                            const SizedBox(height: Dimens.height12),
                          ]),
                        ),
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                              child: Column(
                                children: [
                                  _buildAccordionSection(
                                    title: AppLocalizations.of(ctx)!.diet_type,
                                    isExpanded: _isDietTypeExpanded,
                                    onToggle: () => setState(() => _isDietTypeExpanded = !_isDietTypeExpanded),
                                    child: Column(
                                      children: [
                                        ...state.dietTypes!.map((dietType) {
                                          final isSelected = state.profile!.dietType == dietType.id;
                                          return _buildAccordionItem(
                                            title: dietType.name.orEmpty(),
                                            isSelected: isSelected,
                                            onTap: () {
                                              if (dietType.id == Vegetarian().id) {
                                                bloc.add(AddVegetarianDietsOptions(showVegetarianDiets: !bloc.state.showVegetarianDiets!));
                                              } else {
                                                bloc.add(SetDietTypeAction(dietType: dietType.id));
                                              }
                                            },
                                            isRadio: true,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  _buildAccordionSection(
                                    title: AppLocalizations.of(ctx)!.allergens,
                                    isExpanded: _isAllergensExpanded,
                                    onToggle: () => setState(() => _isAllergensExpanded = !_isAllergensExpanded),
                                    child: Column(
                                      children: [
                                        ...state.allergens!.map((allergen) {
                                          final isSelected = state.profile!.exclusions!.exclusions!.contains(allergen.id);
                                          return _buildAccordionItem(
                                            title: allergen.name.orEmpty(),
                                            isSelected: isSelected,
                                            onTap: () => bloc.add(AddAllergenAction(allergenId: allergen.id!)),
                                            isRadio: false,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  _buildAccordionSection(
                                    title: AppLocalizations.of(ctx)!.intolerances,
                                    isExpanded: _isIntolerancesExpanded,
                                    onToggle: () => setState(() => _isIntolerancesExpanded = !_isIntolerancesExpanded),
                                    child: Column(
                                      children: [
                                        ...state.intolerances!.map((intolerance) {
                                          final isSelected = state.profile!.intolerances!.contains(intolerance.id);
                                          return _buildAccordionItem(
                                            title: intolerance.name.orEmpty(),
                                            isSelected: isSelected,
                                            onTap: () => bloc.add(AddIntolerancesAction(intoleranceId: intolerance.id!)),
                                            isRadio: false,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AversionsScreen.routeName),
                                    child: Container(
                                      padding: const EdgeInsets.all(Dimens.paddingNormal),
                                      decoration: BoxDecoration(
                                        color: AppColors.butter59,
                                        borderRadius: BorderRadius.circular(Dimens.border15),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.of(ctx)!.aversions,
                                              style: AppTextStyles.merriWeather.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: Dimens.fontSizeNormal,
                                                color: AppColors.yellowishGreen,
                                              ),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.yellowishGreen,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimens.height12),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimens.height12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                          child: GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context)),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(Dimens.paddingNormal),
            decoration: BoxDecoration(
              color: isExpanded ? AppColors.yellowishGreen59 : AppColors.butter59,
              borderRadius: isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(Dimens.border15),
                      topRight: Radius.circular(Dimens.border15),
                    )
                  : BorderRadius.circular(Dimens.border15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.merriWeather.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: Dimens.fontSizeNormal,
                      color: isExpanded ? Colors.white : AppColors.yellowishGreen,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: isExpanded ? Colors.white : AppColors.yellowishGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            decoration: const BoxDecoration(
              color: AppColors.floralWhite,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Dimens.border15),
                bottomRight: Radius.circular(Dimens.border15),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall),
            child: child,
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: Dimens.height12),
      ],
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isRadio,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimens.paddingSmall,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimens.border15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: Dimens.paddingLarge,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: Dimens.fontSize15,
                    color: AppColors.yellowishGreen,
                  ),
                ),
              ),
              const SizedBox(width: Dimens.marginSmall),
              Icon(
                isRadio
                    ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_off)
                    : (isSelected ? Icons.check_circle : Icons.circle_outlined),
                color: isSelected ? AppColors.yellowishGreen : AppColors.cloudyGrey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
