import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/bloc/weekly_dashboard_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_energy_graph_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_nutrient_graphic.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';

class WeeklyDashboardDetailScreen extends StatefulWidget {
  static const routeName = '/weekly_dashboard_detail_screen';

  const WeeklyDashboardDetailScreen({super.key});

  @override
  State<WeeklyDashboardDetailScreen> createState() =>
      _WeeklyDashboardDetailScreenState();
}

class _WeeklyDashboardDetailScreenState
    extends State<WeeklyDashboardDetailScreen> {
  late WeeklyDashboardDetailBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<WeeklyDashboardDetailBloc>(context);
    bloc.add(InitialStateEventAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<WeeklyDashboardDetailBloc,
              WeeklyDashboardDetailState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          // if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                // size: 18,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.popAndPushNamed(context, ProfileScreen.routeName)
                        .then((value) {}),
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
          body: Column(
            children: [
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(Dimens.marginLarge),
                  child: Text(AppLocalizations.of(context)!.this_week,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.fontSizeMedium))),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimens.marginLarge),
                    child: Column(
                      children: [
                        WeeklyNutrientGraphic(
                            title: AppLocalizations.of(context)!.micronutrients,
                            data: state.micronutrientsWeekly ?? []),
                        const SizedBox(
                          height: Dimens.heightXSmall,
                        ),
                        WeeklyNutrientGraphic(
                            title: AppLocalizations.of(context)!.macronutrients,
                            data: state.macronutrientsWeekly ?? []),
                        const SizedBox(
                          height: Dimens.heightXSmall,
                        ),
                        WeeklyEnergyGraphWidget(title: AppLocalizations.of(context)!.energy_balance_title,data: state.weeklyEnergyBalance ?? [], averageConsumed: state.averageConsumedKcal ?? 0.0, averageSpent: state.averageSpentKcal ?? 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              CustomBottomAppBar(initStateCallback: () => null),
          resizeToAvoidBottomInset: true,
          floatingActionButton: FloatingActionButton(
            elevation: 2.0,
            backgroundColor: Colors.white,
            onPressed: () =>
                Navigator.popAndPushNamed(context, DashboardScreen.routeName),
            child: Container(
              padding: const EdgeInsets.all(Dimens.paddingSmall),
              child: Image.asset(
                'assets/images/logo_black.png',
                fit: BoxFit.cover,
                color: Colors.black,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      )),
    );
    // SafeArea(child: Scaffold());
  }
}
