import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/bloc/energy_balance_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/energy_balance_detail_widget.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/weekly_energy_graph_widget.dart';

class EnergyBalanceDetailScreen extends StatefulWidget {
  static const routeName = '/energy_balance_detail_screen';

  const EnergyBalanceDetailScreen({super.key});

  @override
  State<EnergyBalanceDetailScreen> createState() =>
      _EnergyBalanceDetailScreenState();
}

class _EnergyBalanceDetailScreenState extends State<EnergyBalanceDetailScreen> with MidnightToastMixin {
  late EnergyBalanceDetailBloc bloc;
  DateTime? _selectedDate;

  @override
  void initState() {
    subscribeMidnight();
    bloc = BlocProvider.of<EnergyBalanceDetailBloc>(context);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.add(InitializeEventAction());
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is Map) {
        final energyModel = infoReceived['energyModel'] as EnergyModel?;
        _selectedDate = infoReceived['selectedDate'] as DateTime?;
        if (energyModel != null) {
          bloc.add(LoadEnergyBalanceEventAction(energyModel: energyModel));
        }
      } else if (infoReceived is EnergyModel) {
        bloc.add(LoadEnergyBalanceEventAction(energyModel: infoReceived));
      }
    });
  }

  @override
  void dispose() {
    unsubscribeMidnight();
    super.dispose();
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
            Stack(
              children: [
                // Background image or gradient
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'), // Your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Blur effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0), // Needed to activate the blur
                  ),
                ),

                Scaffold(
                  backgroundColor: Colors.transparent,
                    body: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingLarge),
                        child: Column(
                          children: [
                            ScreenTopBar(selectedDate: _selectedDate, onBack: () => Navigator.pop(context)),
                            const SizedBox(height: Dimens.height12),
                            HeaderAddItemCardSection(
                              title: AppLocalizations.of(context)!.energy_balance_title,
                            ),
                            EnergyBalanceDetailWidget(
                              energyModel: state.energyModel,
                              weeklyEnergyWidget: WeeklyEnergyGraphWidget(
                                title: AppLocalizations.of(context)!.energy_balance_title,
                                data: state.weeklyEnergyBalance ?? [],
                                averageConsumed: state.averageConsumedKcal ?? 0.0,
                                averageSpent: state.averageSpentKcal ?? 0.0,
                                total: state.energyModel?.totalKcal ?? 0.0,
                              ),),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD)
                ),
              ],
            ),
      ),
    );
  }
}
