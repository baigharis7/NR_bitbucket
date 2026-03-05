import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrientsweekly/bloc/micro_nutrients_weekly_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_item_chart.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';
import '../../../infrastructure/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/weekly_nutrient_graphic.dart';

class MicroNutrientsWeeklyScreen extends StatefulWidget {
  static const routeName = '/micro_nutrients_weekly_screen';

  const MicroNutrientsWeeklyScreen({super.key});

  @override
  State<MicroNutrientsWeeklyScreen> createState() => _MicroNutrientsWeeklyScreenState();
}

class _MicroNutrientsWeeklyScreenState extends State<MicroNutrientsWeeklyScreen> {
  late final MicroNutrientsWeeklyBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<MicroNutrientsWeeklyBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.add(InitializationEventAction());
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is List<NutrientsWeeklyModel>) {
        bloc.add(UpdateWeeklyListOfNutrients(micronutrientsWeekly: infoReceived));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<MicroNutrientsWeeklyBloc, MicroNutrientsWeeklyState>(listener: (ctx, state) {
        if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
      }, builder: (context, state) {
        return Scaffold(
            bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
            body: Stack(
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

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingLarge),
                  child: Column(
                    children: [
                      ScreenTopBar(selectedDate: null, onBack: () => Navigator.pop(context)),
                      const SizedBox(height: Dimens.height12),
                      HeaderAddItemCardSection(
                        title: AppLocalizations.of(context)!.weekly_evolution,
                      ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingLarge),
                    decoration: const BoxDecoration(color: AppColors.floralWhite, borderRadius: BorderRadius.all(Radius.circular(15))),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Image.asset('assets/images/goal_objectives.png', height: 40, width: 40),
                                title: Text(AppLocalizations.of(context)!.micronutrients, style: const TextStyle(
                                    color: AppColors.peacockBlue, fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeMedium, decoration: TextDecoration.underline
                                ),),
                                // trailing: InkWell(onTap: () => Navigator.pushNamed(context, MicroNutrientsWeeklyScreen.routeName, arguments: state.micronutrientsWeekly), child: Image.asset('assets/images/nutrient_graph.png', height: 30, width: 30)),
                              ),
                              // const SizedBox(height: Dimens.height12),
                              ...state.micronutrientsWeekly.orEmpty().map((weeklyNutrientItem) => WeeklyItemChart(weeklyNutrientItem: weeklyNutrientItem,)),
                              // WeeklyItemChart()
                              // WeeklyNutrientGraphic(
                              //   title: AppLocalizations.of(context)!.this_week,
                              //   data: state.micronutrientsWeekly ?? [],),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ));
      },),
    );
  }
}
