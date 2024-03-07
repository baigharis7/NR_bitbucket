import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_food_group_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class RecommendationsTab extends StatefulWidget {

  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
    bloc.add(InitialStateAction());
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
            backgroundColor: Colors.grey[200],
            body: Column(
              children: [
                if (state.showRecommendationCard != null && state.showRecommendationCard!) ExplainingCardsHelper().getExplainingCardWithId(
                  context: context,
                  explainingCardId: ExplainingCardRefs.recommendations.index,
                  onHideCard: () => bloc.add(HideRecommendationsExplainingCardAction()),
                ),
                Container(
                  margin: const EdgeInsets.only(top: Dimens.marginNormal),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
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
                    ],),
                  ),
                ),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall), child: RoundedCustomButton(onPressed: () => bloc.add(UpdateProfileAction()))),
              ],
            ),
            // bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: 2,)
            // CustomBottomAppBar(initStateCallback: () => initState()),
            // resizeToAvoidBottomInset: true,
            // floatingActionButton: FloatingActionButton(
            //   elevation: 2.0,
            //   backgroundColor: Colors.white,
            //   onPressed: () {
            //     bloc.add(EmptyRecommendationAction());
            //     Navigator.popAndPushNamed(context, DashboardScreen.routeName);
            //   },
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
