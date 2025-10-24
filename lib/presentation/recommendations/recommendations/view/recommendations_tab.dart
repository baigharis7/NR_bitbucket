import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_food_group_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class RecommendationsTab extends StatefulWidget {

  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  late RecommendationsGeneralBloc bloc;
  static const htmlString = '''
<p class="blue-text"><b>Blue paragraph:</b> Based on your profile, we recommend foods to include in your diet.</p>
<p class="green-text"><b>Green paragraph:</b> Foods recommended to help you meet your micronutrient goals.</p>
<p class="gray-text"><b>Gray paragraph:</b> Foods you consume frequently.</p>
''';

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
    // bloc.add(InitialStateAction());
  }

  void _showInfoDialog(BuildContext context, Function onDismiss) {
    final mediaQuerySize = MediaQuery.of(context).size;
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: AppColors.white90Percent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border11)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          ListTile(
          minLeadingWidth: Dimens.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: -5),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.peacockBlue,
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 15),
          ),
          title: Text(
            AppLocalizations.of(context)!.information,
            style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
          ),
        ),
        Html(
                data: AppLocalizations.of(context)!.tip_text,
                style: {
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
                    color: AppColors.yellowishGreen,
                    margin: Margins.only(blockEnd: Dimens.marginSmall,),
                  ),
                  'li': Style(
                    color: AppColors.yellowishGreen,
                  ),
                },
              ),
        const SizedBox(height: Dimens.height25),
        ],),
      ),),);
  }

  @override
  Widget build(BuildContext context) {
    // final bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);

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
                  // if (state.showRecommendationCard != null && state.showRecommendationCard!) ExplainingCardsHelper().getExplainingCardWithId(
                  //   context: context,
                  //   explainingCardId: ExplainingCardRefs.recommendations.index,
                  //   // onHideCard: () => bloc.add(HideRecommendationsExplainingCardAction()),
                  // ),
                  // Container(
                  //   margin: const EdgeInsets.only(top: Dimens.marginNormal),
                  // ),
                  ListTile(
                    onTap: () { _showInfoDialog(context, () {}); },
                    trailing: Image.asset('assets/images/info.png', color: AppColors.yellowishGreen, height: Dimens.heightXSmall),
                  ),
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
                  // Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall), child: RoundedCustomButton(onPressed: () => bloc.add(UpdateProfileAction()))),
                ],
              ),
            ),
            bottomNavigationBar: Container(margin: const EdgeInsets.all(Dimens.marginSmall), child: GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => bloc.add(UpdateProfileAction()))),
          );
          },
      ),
    );
  }

}
