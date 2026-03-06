import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_food_group_card.dart';

class RecommendationsTab extends StatefulWidget {

  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  late RecommendationsGeneralBloc bloc;

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
                      'p': Style(
                        fontSize: FontSize(Dimens.fontSizeSmall),
                        color: AppColors.yellowishGreen,
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
                        color: AppColors.yellowishGreen,
                        margin: Margins.only(blockEnd: Dimens.marginSmall),
                        fontSize: FontSize(Dimens.fontSizeSmall),
                      ),
                      'li': Style(
                        color: AppColors.yellowishGreen,
                        fontSize: FontSize(Dimens.fontSizeSmall),
                      ),
                    },
                  ),
                  const SizedBox(height: Dimens.height12),
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
            bottomNavigationBar: Container(margin: const EdgeInsets.all(Dimens.marginSmall), child: GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => bloc.add(UpdateProfileAction()))),
          );
          },
      ),
    );
  }

}
