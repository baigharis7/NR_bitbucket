import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/bloc/liquid_summary_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/liquid_detail_widget.dart';

class LiquidSummaryDetailScreen extends StatefulWidget {
  static const routeName = '/liquid_summary_detail_screen';

  const LiquidSummaryDetailScreen({super.key});

  @override
  State<LiquidSummaryDetailScreen> createState() =>
      _LiquidSummaryDetailScreenState();
}

class _LiquidSummaryDetailScreenState extends State<LiquidSummaryDetailScreen> with MidnightToastMixin {
  late LiquidSummaryDetailBloc bloc;

  @override
  void initState() {
    subscribeMidnight();
    bloc = BlocProvider.of<LiquidSummaryDetailBloc>(context);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is DateTime) {
        bloc.add(LoadLiquidSummaryEventAction(selectedDate: infoReceived));
      } else {
        bloc.add(LoadLiquidSummaryEventAction());
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
      child: SafeArea(
          child:
              BlocConsumer<LiquidSummaryDetailBloc, LiquidSummaryDetailState>(
        listener: (ctx, state) {
          // if (state.isLoading) {
          //   LoadingScreen.instance().show(
          //     context: ctx,
          //     text: AppLocalizations.of(ctx)!.loading,
          //   );
          // } else {
          //   LoadingScreen.instance().hide();
          // }
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
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
                  onPressed: () => Navigator.popAndPushNamed(
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
                  child: Text(
                      bloc.getTodayMessage(AppLocalizations.of(context)!.today,
                          Localizations.localeOf(context).languageCode),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.fontSizeMedium)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        LiquidDetailWidget(
                          quantityTaken: EventsHelper().getWaterIntakeAddition(
                            state.waterEvents,
                            [],
                            [],
                          ),
                          fractionToFill:
                              EventsHelper().getWaterFractionToFillFromEvents(
                            state.waterEvents,
                            [],
                                [],
                                ((state.userProfile?.physicalCharacteristics?.weight ?? 0) * 0.035),
                          ),
                          removeWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_REMOVE_WATER_QUANTITY, onFinish: () {})),
                          addWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_ADD_WATER_QUANTITY, onFinish: () {})),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const CustomBottomNaviBarWidget(
                activePosition: Constants.DASHBOARD)
            // CustomBottomAppBar(initStateCallback: () => null),
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
            ),
      )),
    );
    // SafeArea(child: Scaffold());
  }
}
