import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_item_with_edit_and_like.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_info_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class JournalFoodScreen extends StatefulWidget {
  const JournalFoodScreen({Key? key}) : super(key: key);

  static const routeName = '/journal_food';

  @override
  State<StatefulWidget> createState() => _JournalFoodScreenState();
}

class _JournalFoodScreenState extends State<JournalFoodScreen> {

  @override
  void initState() {
    final bloc = BlocProvider.of<JournalFoodBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<JournalFoodBloc>(context);
    final mediaQuerySize = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<JournalFoodBloc, JournalFoodState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: ctx,
                text: AppLocalizations.of(ctx)!.loading,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (ctx, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              // TODO: meter AppBar en un widget configurable.
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.food,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: Dimens.fontSizeXXLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 28,
                          margin: const EdgeInsets.only(left: Dimens.marginNormal),
                          child: Image.asset('assets/icon/fork_knife.png'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                          icon: const Icon(Icons.add_circle, color: Colors.teal,),
                        )
                      ],
                    )
                  ],
                ),
              ),
              body: SizedBox(
                width: mediaQuerySize.width,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginNormal),
                          child: Text(AppLocalizations.of(context)!.today, style: const TextStyle(fontWeight: FontWeight.bold,),),
                        ),
                        if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                          context: context,
                          explainingCardId: ExplainingCardRefs.addNewFoodEvent.index,
                          onHideCard: () => bloc.add(HideExplainingCardAction()),
                          onPressedButton: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName),
                        ),
                        state.todayFoodEvents!.isNotEmpty
                        ? GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0,
                            childAspectRatio: 3/2,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...state.todayFoodEvents!.map((foodEvent) {
                              return EventItemWithEditAndLike(
                                name: foodEvent.foodInfo!.map((food) => food.translate(context)).join(', '),
                                isFavorite: /** TODO: lógica del */false,
                                onEdit: () => Navigator.pushNamed(
                                  context,
                                  AddFoodEventScreen.routeName,
                                  arguments: mapToFoodEventSimple(foodEvent),
                                ).then((value) {
                                  bloc.add(InitializeStateAction());
                                }),
                                onFavorite: () => Navigator.pushNamed(
                                  context,
                                  AddFoodFavoriteScreen.routeName,
                                  arguments: mapToFoodFavoriteList(foodEvent.foodInfo!),
                                ).then((value) {
                                  bloc.add(InitializeStateAction());
                                }),
                              );
                            }).toList()
                          ],
                        )
                        : Container(
                          margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                          child: Text(AppLocalizations.of(context)!.no_food_events),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
                          child: Text(AppLocalizations.of(context)!.this_week, style: const TextStyle(fontWeight: FontWeight.bold,),),
                        ),
                        WeeklyInfoCard(
                          weeklyData: state.weeklyData ?? [],
                          kcals: state.userKcal!,
                          cardElevation: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: const CustomBottomAppBar(initStateCallback: null,),
              resizeToAvoidBottomInset: true,
              floatingActionButton: FloatingActionButton(
                elevation: 2.0,
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
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
      ),
    );
  }

}