import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/micro_nutrient_detail_widget.dart';
import '../../widgets/weekly_nutrient_graphic.dart';

class MicroNutrientsDetailScreen extends StatefulWidget {
  static const routeName = '/micro_nutrients_detail_screen';

  const MicroNutrientsDetailScreen({super.key});

  @override
  State<MicroNutrientsDetailScreen> createState() =>
      _MicroNutrientsDetailScreenState();
}


class _MicroNutrientsDetailScreenState
    extends State<MicroNutrientsDetailScreen> {
  late final MicroNutrientsDetailBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<MicroNutrientsDetailBloc>(context);
    bloc.add(InitializationEventAction());
    super.initState();

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is List<NutrientsModel>?) {
            final micronutrientsList = infoReceived as List<NutrientsModel>?;
            bloc.add(LoadMicroNutrientsDetails(micronutrientsList: micronutrientsList ?? []));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // List<NutrientsModel>? micronutrientsList = <NutrientsModel>[];
    // if (ModalRoute.of(context)?.settings.arguments != null) {
    //   final infoReceived = ModalRoute.of(context)?.settings.arguments;
    //   if (infoReceived != null) {
    //     if (infoReceived is List<NutrientsModel>?) {
    //       micronutrientsList = infoReceived as List<NutrientsModel>?;
    //       bloc.add(LoadMicroNutrientsDetails(micronutrientsList: micronutrientsList ?? []));
    //     }
    //   }
    // }

    return BlocProvider.value(value: bloc,
      child: SafeArea(
        child: BlocConsumer<MicroNutrientsDetailBloc, MicroNutrientsDetailState>(listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          // if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        }, builder: (context, state) => Scaffold(
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
                child:
                Text(bloc.getTodayMessage(AppLocalizations.of(context)!.today, Localizations.localeOf(context).languageCode), style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontSizeMedium)),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall, horizontal: Dimens.marginLarge),
                child: Text((AppLocalizations.of(context)!.micronutrients_achieve_object), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium),),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                      child: WeeklyNutrientGraphic(
                          title: AppLocalizations.of(context)!.this_week,
                          data: state.micronutrientsWeekly ?? [],),
                    ),
                    ...state.microNutrients.orEmpty().map((item) =>
                    // item.fractionToFill > 0 ?
                    MicroNutrientDetailWidget(nutrientsModel: item,),
                      // : Container(),
                    ),
                  ],),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD)
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
        ),),
      ),);
  }
}
