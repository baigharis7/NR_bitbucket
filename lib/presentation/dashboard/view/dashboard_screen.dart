import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/view/energy_balance_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/view/liquid_summary_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/view/macro_nutrients_detail.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/view/sugar_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/view/weekly_dashboard_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/energy_balance_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/liquids_summary_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrients_dashboard_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_rda_nutrients_dashboard_widget.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../fiber_detail/view/fiber_detail_Screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    final bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.add(InitializeState());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);
    final mediaQuerySize = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<DashboardBloc, DashboardState>(
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
              appBar: AppBar(
                title: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: Dimens.marginNormal,),
                  child: Text(
                    AppLocalizations.of(context)!.welcome,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeLarge,
                      color: Colors.black,
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName).then((value) => bloc.add(InitializeState())),
                    iconSize: 35.0,
                    icon: Image.asset(
                      'assets/icon/profile_icon.png',
                      color: Colors.black,
                      height: 29,
                      width: 29,
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(onPressed: () => Navigator.pushNamed(context, WeeklyDashboardDetailScreen.routeName).then((value) => bloc.add(InitializeState())), icon: const Icon(Icons.arrow_drop_down_circle_outlined)),
                            Text(bloc.getTodayMessage(AppLocalizations.of(context)!.today, Localizations.localeOf(context).languageCode),)
                          ],
                        ),
                        NutrientsDashboardWidget(
                          title: AppLocalizations.of(context)!.micronutrients,
                          nutrients: state.micronutrients.orEmpty().take(Constants.DASHBOARD_LIST_SIZE).toList(),
                          isEmpty: false,
                          screenToMove: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: state.micronutrients.orEmpty()).then((value) => bloc.add(InitializeState())),
                        ),
                        NutrientsDashboardWidget(
                          title: AppLocalizations.of(context)!.macronutrients,
                          nutrients: state.macronutrients.orEmpty(),
                          // isEmpty: state.foodEvents.isNull() ? true : state.foodEvents!.isEmpty,
                          isEmpty: false,
                          screenToMove: () => Navigator.pushNamed(context, MacroNutrientsDetailScreen.routeName, arguments: state.macronutrients.orEmpty()).then((value) => bloc.add(InitializeState())),
                        ),
                        WeeklyRDANutrientsDashboardWidget(
                          title: AppLocalizations.of(context)!.weekly_nutrients,
                          nutrients: state.weeklyMicronutrients.orEmpty(),
                          isEmpty: state.foodEvents.isNull() ? true : state.foodEvents!.isEmpty,
                          screenToMove: () {},
                        ),
                        EnergyBalanceWidget(
                          energyModel: state.energyModel,
                          screenToMove: () => Navigator.pushNamed(context, EnergyBalanceDetailScreen.routeName, arguments: state.energyModel).then((value) => bloc.add(InitializeState())),
                        ),
                        SizedBox(
                          height: 200,
                          child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: LiquidSummaryWidget(
                                    quantityTaken: EventsHelper().getWaterIntakeAddition(state.waterEvents),
                                    fractionToFill: EventsHelper().getWaterFractionToFillFromEvents(state.waterEvents),
                                    onReloadData: () => bloc.add(ReloadWaterInfoAction()),
                                    screenToMove: () => Navigator.pushNamed(context, LiquidSummaryDetailScreen.routeName, arguments: state.waterEvents).then((value) => bloc.add(InitializeState())),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Opacity(
                                    opacity: 0.4,
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!.steps,
                                                  style: const TextStyle(
                                                    fontSize: Dimens.fontSizeNormal,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.centerRight,
                                                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 80,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey,
                                            ),
                                            child: const Center(child: Text('2000'),),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(top: Dimens.marginNormal),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: const [
                                                Text('5,4 km'),
                                                Text('98 min')
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.all(Dimens.marginNormal),
                                      child: Text(
                                        AppLocalizations.of(context)!.sugar,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  IconButton(onPressed: () => Navigator.pushNamed(context, SugarDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState())), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                                child: FillHorizontalBar(fractionToFill: state.sugarAndFiberModel?.fractionToFillSugar ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  (state.sugarAndFiberModel?.totalSugar.toString() ?? '0').appendGram(),
                                  style: const TextStyle(fontSize: Dimens.fontSizeSmall),
                                ),
                              )
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.all(Dimens.marginNormal),
                                      child: Text(
                                        AppLocalizations.of(context)!.fiber,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  IconButton(onPressed: () => Navigator.pushNamed(context, FiberDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState())), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                                child: FillHorizontalBar(fractionToFill: state.sugarAndFiberModel?.fractionToFillFiber ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  (state.sugarAndFiberModel?.totalFiber.toString() ?? '0').appendGram(),
                                  style: const TextStyle(fontSize: Dimens.fontSizeSmall),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (state.showCard != null && state.showCard!) Positioned(
                      top: 100,
                      width: mediaQuerySize.width,
                      child: ExplainingCardsHelper().getExplainingCardWithId(
                        context: context,
                        explainingCardId: ExplainingCardRefs.dashboard.index,
                        onHideCard: () => bloc.add(HideCardAction()),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomAppBar(initStateCallback: () => bloc.add(InitializeState())),
              resizeToAvoidBottomInset: true,
              floatingActionButton: FloatingActionButton(
                elevation: 2.0,
                backgroundColor: Colors.white,
                onPressed: () {},
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