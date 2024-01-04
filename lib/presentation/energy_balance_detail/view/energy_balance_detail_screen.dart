import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/bloc/energy_balance_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/energy_balance_detail_widget.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/weekly_energy_graph_widget.dart';

class EnergyBalanceDetailScreen extends StatefulWidget {
  static const routeName = '/energy_balance_detail_screen';

  const EnergyBalanceDetailScreen({super.key});

  @override
  State<EnergyBalanceDetailScreen> createState() =>
      _EnergyBalanceDetailScreenState();
}

class _EnergyBalanceDetailScreenState extends State<EnergyBalanceDetailScreen> {
  late EnergyBalanceDetailBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<EnergyBalanceDetailBloc>(context);
    bloc.add(InitializeEventAction());
    super.initState();

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is EnergyModel?) {
            bloc.add(LoadEnergyBalanceEventAction(energyModel: infoReceived as EnergyModel));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
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
        builder: (context, state) =>
            SafeArea(
                child: Scaffold(
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
                            Navigator.popAndPushNamed(
                                context, ProfileScreen.routeName)
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
                        child: Text(bloc.getTodayMessage(
                          AppLocalizations.of(context)!.today,
                          Localizations
                              .localeOf(context)
                              .languageCode,), style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimens.fontSizeMedium)),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
                                child: WeeklyEnergyGraphWidget(
                                  title: AppLocalizations.of(context)!.energy_balance_title,
                                  data: state.weeklyEnergyBalance ?? [],
                                  averageConsumed: state.averageConsumedKcal ?? 0.0,
                                  averageSpent: state.averageSpentKcal ?? 0.0,
                                ),
                              ),
                              // EnergyBalanceDetailWidget(energyModel: EnergyModel(fractionToFill: 0.2, rawKcalTaken: 10, spentKcal: 2, totalKcal: 20)),
                              EnergyBalanceDetailWidget(energyModel: state.energyModel),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: CustomBottomAppBar(
                      initStateCallback: () => null),
                  resizeToAvoidBottomInset: true,
                  floatingActionButton: FloatingActionButton(
                    elevation: 2.0,
                    backgroundColor: Colors.white,
                    onPressed: () =>
                        Navigator.popAndPushNamed(
                            context, DashboardScreen.routeName),
                    child: Container(
                      padding: const EdgeInsets.all(Dimens.paddingSmall),
                      child: Image.asset(
                        'assets/images/logo_black.png',
                        fit: BoxFit.cover,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation
                      .centerDocked,)
            ),
      ),
    );
  }
}
