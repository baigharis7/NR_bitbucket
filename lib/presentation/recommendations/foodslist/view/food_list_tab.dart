import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/remove_item_widget.dart';

class FoodListScreen extends StatefulWidget {
  final List<SimpleItem> foodItems;

  const FoodListScreen({
    Key? key,
    required this.foodItems,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodListScreen();
}

class _FoodListScreen extends State<FoodListScreen> {

  void _showRemoveDialog({required String foodName, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => RemoveItemWidget(
        description: foodName,
        onConfirm: onConfirm,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFoodCard({
    required String foodName,
    String? foodGroupName,
    required Color color,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimens.marginNormal,
        vertical: 4,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.border15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 7,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimens.paddingNormal,
                  horizontal: Dimens.paddingNormal,
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
                              fontSize: Dimens.fontSizeNormal,
                              color: color,
                            ),
                          ),
                          if (foodGroupName != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              foodGroupName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyles.merriWeather.copyWith(
                                fontWeight: FontWeight.w300,
                                fontSize: Dimens.fontSize13,
                                color: color.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimens.marginSmall),
                    GestureDetector(
                      onTap: onDelete,
                      child: Image.asset(
                        'assets/images/delete_icon.png',
                        width: 24,
                        height: 24,
                        color: color,
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

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
                    child: Text(
                      AppLocalizations.of(context)!.food_list_explaining_card,
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize13, color: AppColors.yellowishGreen),
                    ),
                  ),
                  const SizedBox(height: Dimens.height12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
                    child: Text(
                      AppLocalizations.of(context)!.my_foods_list,
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeMedium, color: AppColors.yellowishGreen),
                    ),
                  ),
                  const SizedBox(height: Dimens.height12),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: state.foodItems?.length ?? 0,
                    itemBuilder: (context, index) {
                      final foodItem = state.foodItems.orEmpty()[index];
                      final foodName = bloc.findFood(foodItem.id).translate(context);
                      final foodGroup = bloc.findFoodGroup(foodItem.id);
                      final categoryType = bloc.findFoodCategoryType(foodItem.id);
                      final color = categoryType == 0
                          ? AppColors.peacockBlue
                          : categoryType == 1
                              ? AppColors.green
                              : AppColors.yellowishGreen;
                      return _buildFoodCard(
                        foodName: foodName,
                        foodGroupName: foodGroup?.translate(context),
                        color: color,
                        onDelete: () {
                          _showRemoveDialog(
                            foodName: foodName,
                            onConfirm: () => bloc.add(OnDeleteFoodIdFromList(foodItem: foodItem)),
                          );
                        },
                      );
                    },),
                ],
              ),
            ),
            // bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: 2,)
            // CustomBottomAppBar(initStateCallback: () => initState()),
            // resizeToAvoidBottomInset: true,
            // floatingActionButton: FloatingActionButton(
            //   elevation: 2.0,
            //   backgroundColor: Colors.white,
            //   onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
            //   child: Container(
            //     padding: const EdgeInsets.all(Dimens.paddingSmall),
            //     child: Image.asset(
            //       'assets/images/logo_black.png',
            //       fit: BoxFit.cover,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

}