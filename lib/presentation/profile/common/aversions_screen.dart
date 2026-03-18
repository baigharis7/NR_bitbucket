import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';

import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/screen_top_bar.dart';

class AversionsScreen extends StatefulWidget {
  static const routeName = '/aversions';

  const AversionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AversionsScreenState();
}

class _AversionsScreenState extends State<AversionsScreen> {
  late ProfileBloc bloc;
  late List<int> _initialFoodAversions;
  final Set<int> _expandedFoodGroups = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    bloc = BlocProvider.of<ProfileBloc>(context);
    _initialFoodAversions = List<int>.from(bloc.state.profile!.foodAversions!);
    super.initState();
  }

  void _onBack() {
    // Restore original aversions (cancel changes)
    bloc.state.profile!.foodAversions!.clear();
    bloc.state.profile!.foodAversions!.addAll(_initialFoodAversions);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              _onBack();
              return Future.value(false);
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
                            ScreenTopBar(onBack: () => _onBack()),
                            const SizedBox(height: Dimens.height12),
                            HeaderAddItemCardSection(
                              title: AppLocalizations.of(context)!.aversions,
                              image: 'assets/images/meal_time_1.png',
                            ),
                            const SizedBox(height: Dimens.height12),
                          ]),
                        ),
                        // Search bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                            style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize13, color: AppColors.yellowishGreen),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(ctx)!.search,
                              hintStyle: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize13, color: AppColors.cloudyGrey),
                              prefixIcon: const Icon(Icons.search, color: AppColors.yellowishGreen, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      }),
                                      child: const Icon(Icons.close, color: AppColors.cloudyGrey, size: 18),
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimens.border15),
                                borderSide: const BorderSide(color: AppColors.cloudyGrey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimens.border15),
                                borderSide: const BorderSide(color: AppColors.cloudyGrey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimens.border15),
                                borderSide: const BorderSide(color: AppColors.yellowishGreen),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimens.height12),
                        // Food group accordions
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                              child: Column(
                                children: [
                                  ...state.aversionsUI!.foodGroups.where((foodGroup) {
                                    if (_searchQuery.isEmpty) return true;
                                    if (foodGroup.name.toLowerCase().contains(_searchQuery)) return true;
                                    return foodGroup.foodsList.any((food) => food.name.toLowerCase().contains(_searchQuery));
                                  }).map((foodGroup) {
                                    final isGroupExpanded = _expandedFoodGroups.contains(foodGroup.id);
                                    final filteredFoods = _searchQuery.isEmpty
                                        ? foodGroup.foodsList
                                        : foodGroup.foodsList.where((food) => food.name.toLowerCase().contains(_searchQuery)).toList();
                                    return _buildFoodGroupAccordion(
                                      title: foodGroup.name,
                                      isExpanded: isGroupExpanded || _searchQuery.isNotEmpty,
                                      onToggle: () => setState(() {
                                        if (isGroupExpanded) {
                                          _expandedFoodGroups.remove(foodGroup.id);
                                        } else {
                                          _expandedFoodGroups.add(foodGroup.id);
                                        }
                                      }),
                                      foods: filteredFoods,
                                      foodAversions: state.profile!.foodAversions!,
                                    );
                                  }),
                                  const SizedBox(height: Dimens.height12),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimens.height12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
                          child: GeneralButton(title: AppLocalizations.of(context)!.ok, onTap: () => Navigator.pop(context)),
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

  Widget _buildFoodGroupAccordion({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List foods,
    required List<int> foodAversions,
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
            child: Column(
              children: [
                ...foods.map((food) {
                  final isSelected = foodAversions.contains(food.id);
                  return GestureDetector(
                    onTap: () => bloc.add(ManageAversionsAction(foodId: food.id)),
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
                                food.name,
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
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? AppColors.yellowishGreen : AppColors.cloudyGrey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: Dimens.height12),
      ],
    );
  }
}
