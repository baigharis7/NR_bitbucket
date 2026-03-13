import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_food_group_card.dart';

class RecommendationsTab extends StatefulWidget {

  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  late RecommendationsGeneralBloc bloc;
  bool _isRecentsExpanded = false;
  bool _isFavoritesExpanded = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<RecommendationsGeneralBloc, RecommendationsGeneralState>(
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
          return Scaffold(
            backgroundColor: AppColors.white70Percent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimens.paddingNormal),
              child: Column(
                children: [
                  Html(
                    data: AppLocalizations.of(context)!.tip_text,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.only(left: Dimens.paddingSmall, right: Dimens.paddingSmall),
                      ),
                      'p': Style(
                        fontFamily: 'MerriWeather',
                        fontSize: FontSize(Dimens.fontSize13),
                        color: AppColors.yellowishGreen,
                        margin: Margins.only(top: 0, bottom: Dimens.marginSmall),
                      ),
                      '.blue-text': Style(
                        color: AppColors.peacockBlue,
                      ),
                      '.green-text': Style(
                        color: AppColors.green,
                      ),
                      '.yellowish-green-text': Style(
                        color: AppColors.yellowishGreen,
                      ),
                      'ul': Style(
                        fontFamily: 'MerriWeather',
                        color: AppColors.yellowishGreen,
                        margin: Margins.only(top: 0, bottom: Dimens.marginSmall),
                        padding: HtmlPaddings.only(left: Dimens.paddingNormal),
                        fontSize: FontSize(Dimens.fontSize13),
                      ),
                      'li': Style(
                        fontFamily: 'MerriWeather',
                        color: AppColors.yellowishGreen,
                        fontSize: FontSize(Dimens.fontSize13),
                      ),
                    },
                  ),
                  const SizedBox(height: Dimens.height12),
                  _buildRecentsAccordion(ctx, state),
                  _buildFavoritesAccordion(ctx, state),
                  ...state.recommendationFoodsItems!.map((recommendationItem) {
                    return RecommendationsFoodGroupCard(
                      recommendationsFoodItem: recommendationItem,
                      onAdd: (FoodItemMaster foodItemMaster) {
                        final name = foodItemMaster.translate(ctx);
                        bloc.add(ManageFoodToListAction(
                          foodItem: SimpleItem(
                            id: foodItemMaster.id!,
                            name: name,
                          ),
                        ),);
                      },
                      isChecked: (int id) => state.foodItems.orEmpty().map((simpleItem) => simpleItem.id).toList().contains(id),
                    );
                  }),
                ],
              ),
            ),
          );
          },
      ),
    );
  }

  /// Returns the category color for a food ID based on which recommendation list it belongs to.
  /// Falls back to peacockBlue if not found in any recommendation group.
  Color _colorForFoodId(int foodId) {
    final categoryType = bloc.findFoodCategoryType(foodId);
    switch (categoryType) {
      case 0: return AppColors.peacockBlue;   // objective
      case 1: return AppColors.green;          // deficit
      case 2: return AppColors.yellowishGreen; // usual unhealthy
      case 3: return AppColors.yellowishGreen; // usual healthy
      default: return AppColors.peacockBlue;   // not in recommendations
    }
  }

  Widget _buildRecentsAccordion(BuildContext ctx, RecommendationsGeneralState state) {
    final events = state.recentFoodEvents;

    // Build unique food items with occurrence counts
    final foodCounts = <int, _RecentFoodEntry>{};
    if (events != null) {
      for (final event in events) {
        for (final food in event.foodInfo ?? <FoodInfo>[]) {
          if (food.id == null) continue;
          if (foodCounts.containsKey(food.id!)) {
            foodCounts[food.id!]!.count++;
          } else {
            foodCounts[food.id!] = _RecentFoodEntry(foodInfo: food, count: 1);
          }
        }
      }
    }
    final sortedFoods = foodCounts.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return _buildAccordionSection(
      ctx: ctx,
      title: AppLocalizations.of(context)!.recent,
      isExpanded: _isRecentsExpanded,
      onToggle: () => setState(() => _isRecentsExpanded = !_isRecentsExpanded),
      isLoading: events == null,
      isEmpty: sortedFoods.isEmpty,
      emptyText: AppLocalizations.of(context)!.no_recent_foods,
      itemCount: sortedFoods.length,
      itemBuilder: (index) {
        final entry = sortedFoods[index];
        // Try FoodInfo.translate first, fall back to master file lookup
        var foodName = entry.foodInfo.translate(ctx);
        if (foodName.isEmpty) {
          foodName = bloc.findFood(entry.foodInfo.id!).translate(ctx);
        }
        final isInList = state.foodItems?.any((item) => item.id == entry.foodInfo.id) ?? false;
        final color = _colorForFoodId(entry.foodInfo.id!);
        return _buildAccordionFoodItem(
          foodName: foodName,
          subtitle: AppLocalizations.of(context)!.times_eaten(entry.count),
          color: color,
          isInList: isInList,
          onAdd: () {
            bloc.add(ManageFoodToListAction(
              foodItem: SimpleItem(name: '', id: entry.foodInfo.id!),
            ));
          },
        );
      },
    );
  }

  Widget _buildFavoritesAccordion(BuildContext ctx, RecommendationsGeneralState state) {
    final favorites = state.foodFavorites;

    // Collect unique food items from all favorites
    final uniqueFoods = <int, FoodInFavorite>{};
    if (favorites != null) {
      for (final fav in favorites) {
        for (final ingredient in fav.ingredients) {
          uniqueFoods.putIfAbsent(ingredient.id, () => ingredient);
        }
        for (final drink in fav.drinks) {
          uniqueFoods.putIfAbsent(drink.id, () => drink);
        }
      }
    }
    final foodList = uniqueFoods.values.toList();

    return _buildAccordionSection(
      ctx: ctx,
      title: AppLocalizations.of(context)!.favorites,
      isExpanded: _isFavoritesExpanded,
      onToggle: () => setState(() => _isFavoritesExpanded = !_isFavoritesExpanded),
      isLoading: favorites == null,
      isEmpty: foodList.isEmpty,
      emptyText: AppLocalizations.of(context)!.no_favorites,
      itemCount: foodList.length,
      itemBuilder: (index) {
        final food = foodList[index];
        // Try FoodInFavorite.translate first, fall back to master file lookup
        var foodName = food.translate(ctx);
        if (foodName.isEmpty) {
          foodName = bloc.findFood(food.id).translate(ctx);
        }
        final isInList = state.foodItems?.any((item) => item.id == food.id) ?? false;
        final color = _colorForFoodId(food.id);
        return _buildAccordionFoodItem(
          foodName: foodName,
          color: color,
          isInList: isInList,
          onAdd: () {
            bloc.add(ManageFoodToListAction(
              foodItem: SimpleItem(name: '', id: food.id),
            ));
          },
        );
      },
    );
  }

  Widget _buildAccordionSection({
    required BuildContext ctx,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required bool isLoading,
    required bool isEmpty,
    required String emptyText,
    required int itemCount,
    required Widget Function(int) itemBuilder,
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
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(Dimens.paddingNormal),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.paddingNormal,
                          vertical: Dimens.paddingLarge,
                        ),
                        child: Center(
                          child: Text(
                            emptyText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.merriWeather.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: Dimens.fontSize13,
                              color: AppColors.yellowishGreen,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: List.generate(itemCount, itemBuilder),
                      ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: Dimens.height12),
      ],
    );
  }

  Widget _buildAccordionFoodItem({
    required String foodName,
    String? subtitle,
    required Color color,
    required bool isInList,
    required VoidCallback onAdd,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingSmall,
        vertical: 3,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.border15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 7, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: Dimens.paddingSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            foodName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: AppTextStyles.merriWeather.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: Dimens.fontSize13,
                              color: color,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: AppTextStyles.merriWeather.copyWith(
                                fontWeight: FontWeight.w300,
                                fontSize: Dimens.fontSize11,
                                color: color.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimens.marginSmall),
                    GestureDetector(
                      onTap: onAdd,
                      child: Icon(
                        isInList ? Icons.check_circle : Icons.add_circle_outline,
                        color: isInList ? AppColors.green : color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentFoodEntry {
  final FoodInfo foodInfo;
  int count;

  _RecentFoodEntry({required this.foodInfo, required this.count});
}
