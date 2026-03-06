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
import 'package:nutrenaissance_flutter/presentation/widgets/food_list_item.dart';

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

  void _showDelFoodDialog({required Function onDelFood,}) {
    showDialog(context: context, builder: (context) => SimpleDialog(
      backgroundColor: AppColors.mountainMeadowLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.mountainMeadow, width: 2)),
      children: [
        SizedBox(child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.cancel_outlined, color: AppColors.mountainMeadow,), alignment: Alignment.centerRight), width: double.infinity),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.remove_food, style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mountainMeadow,
                  fontSize: Dimens.fontSizeNormal), textAlign: TextAlign.center),
              const SizedBox(height: Dimens.heightXSmall),
              Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXXLarge, vertical: Dimens.paddingNormal),
                          decoration: const BoxDecoration(color: AppColors.mountainMeadow,shape: BoxShape.rectangle, borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(5), bottomStart: Radius.circular(5))),
                          child: Text(AppLocalizations.of(context)!.keep, style: const TextStyle(color: Colors.white),),),
                      ),
                      const SizedBox(width: 2,),
                      InkWell(
                        onTap: () { onDelFood.call(); Navigator.pop(context); },
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingNormal),
                          decoration: const BoxDecoration(color: AppColors.mountainMeadow,shape: BoxShape.rectangle, borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(5), bottomEnd: Radius.circular(5))),
                          child: Text(AppLocalizations.of(context)!.remove, style: const TextStyle(color: Colors.white),),),
                      ),
                    ],),
                  alignment: Alignment.centerRight,
              ),
              const SizedBox(height: Dimens.heightXSmall),
            ],),
        )
      ],
    ));
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
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeSmall, color: AppColors.yellowishGreen),
                    ),
                  ),
                  const SizedBox(height: Dimens.height12),
                  Text(
                    AppLocalizations.of(context)!.my_foods_list,
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeMedium, color: Colors.black),
                  ),
                  const SizedBox(height: Dimens.height12),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: state.foodItems?.length ?? 0,
                    itemBuilder: (context, index) {
                      final foodItem = state.foodItems.orEmpty()[index];
                      return FoodListItem(
                        foodName: bloc.findFood(foodItem.id).translate(context),
                        // onDelete: () => bloc.add(OnDeleteFoodIdFromList(foodItem: foodItem)),
                        onDelete: () {
                          _showDelFoodDialog(onDelFood: () => bloc.add(OnDeleteFoodIdFromList(foodItem: foodItem)));
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