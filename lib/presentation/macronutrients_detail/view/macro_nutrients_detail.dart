import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/macro_nutrient_detail_widget.dart';
import '../../widgets/weekly_nutrient_graphic.dart';

class MacroNutrientsDetailScreen extends StatefulWidget {
  static const routeName = '/macro_nutrients_detail';

  const MacroNutrientsDetailScreen({super.key});

  @override
  State<MacroNutrientsDetailScreen> createState() => _MacroNutrientsDetailScreenState();
}

class _MacroNutrientsDetailScreenState extends State<MacroNutrientsDetailScreen> {
  late MacroNutrientsDetailBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<MacroNutrientsDetailBloc>(context);
    bloc.add(InitializeEventAction());
    super.initState();

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is List<NutrientsModel>?) {
            final macronutrientsList = infoReceived as List<NutrientsModel>?;
            bloc.add(LoadMacroNutrientsEventAction(macronutrientsList: macronutrientsList));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<MacroNutrientsDetailBloc, MacroNutrientsDetailState>(
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
                  child: Text(bloc.getTodayMessage(
                      AppLocalizations.of(context)!.today,
                      Localizations.localeOf(context).languageCode,), style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimens.fontSizeMedium)),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      vertical: Dimens.marginXSmall,
                      horizontal: Dimens.marginLarge),
                  child: Text(
                    (AppLocalizations.of(context)!.macronutrients),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Dimens.fontSizeMedium),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                          child: WeeklyNutrientGraphic(
                            title: AppLocalizations.of(context)!.this_week,
                            data: state.macronutrientsWeekly ?? [],),
                        ),
                        ...state.macronutrients.orEmpty().map((item) {
                          var description = '';
                          if (item.nutrientInfoMaster.officialName == 'proteinSci') {
                            description = AppLocalizations.of(context)!.protein;
                          }
                          if (item.nutrientInfoMaster.officialName == 'carbsAvailable') {
                            description = AppLocalizations.of(context)!.carbohydrates;
                          }
                          if (item.nutrientInfoMaster.officialName == 'fatTotal') {
                            description = AppLocalizations.of(context)!.fat;
                          }
                          // if(item.fractionToFill > 0 ) {
                            return MacroNutrientDetailWidget(nutrientsModel: item, description: description,);
                          // }
                          // else {
                          //   return Container();
                          // }
                        }),
                      ],
                    ),
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
          ),
        ),
      ),
    );
  }
}
