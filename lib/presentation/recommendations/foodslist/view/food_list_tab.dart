import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
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
            backgroundColor: Colors.grey[100],
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(Dimens.marginNormal),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    if (state.showFoodListCard != null && state.showFoodListCard!) ExplainingCardsHelper().getExplainingCardWithId(
                      context: context,
                      explainingCardId: ExplainingCardRefs.foodList.index,
                      onHideCard: () => bloc.add(HideFoodListExplainingCardAction()),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginNormal),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: Text(
                              AppLocalizations.of(context)!.my_foods_list.appendColon(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimens.fontSizeNormal,
                              ),
                            ),
                          ),
                          ...state.foodItems!.map((foodItem) => FoodListItem(
                            foodName: foodItem.name,
                            onDelete: () => bloc.add(OnDeleteFoodIdFromList(foodItem: foodItem)),
                          ),)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CustomBottomAppBar(initStateCallback: () => initState()),
            resizeToAvoidBottomInset: true,
            floatingActionButton: FloatingActionButton(
              elevation: 2.0,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
              child: Container(
                padding: const EdgeInsets.all(Dimens.paddingSmall),
                child: Image.asset(
                  'assets/images/logo_black.png',
                  fit: BoxFit.cover,
                  color: Colors.black,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

}