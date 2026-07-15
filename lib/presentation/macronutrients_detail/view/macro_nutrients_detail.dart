import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/macro_nutrient_detail_widget.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/weekly_nutrient_graphic.dart';

class MacroNutrientsDetailScreen extends StatefulWidget {
  static const routeName = '/macro_nutrients_detail';

  const MacroNutrientsDetailScreen({super.key});

  @override
  State<MacroNutrientsDetailScreen> createState() => _MacroNutrientsDetailScreenState();
}

class _MacroNutrientsDetailScreenState extends State<MacroNutrientsDetailScreen> with MidnightToastMixin {
  late MacroNutrientsDetailBloc bloc;
  DateTime? _selectedDate;

  @override
  void initState() {
    subscribeMidnight();
    bloc = BlocProvider.of<MacroNutrientsDetailBloc>(context);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.add(InitializeEventAction());
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is Map) {
        final macronutrientsList = infoReceived['macronutrients'] as List<NutrientsModel>?;
        _selectedDate = infoReceived['selectedDate'] as DateTime?;
        bloc.add(LoadMacroNutrientsEventAction(macronutrientsList: macronutrientsList));
      } else if (infoReceived is List<NutrientsModel>?) {
        bloc.add(LoadMacroNutrientsEventAction(macronutrientsList: infoReceived));
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
        },
        builder: (context, state) =>
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0),
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
                            title: AppLocalizations.of(context)!.macronutrients,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                            child: WeeklyNutrientGraphic(
                              title: AppLocalizations.of(context)!.this_week,
                              data: state.macronutrientsWeekly ?? [],),
                          ),
                          ...state.macronutrients.orEmpty().map((item) {
                            var description = '';
                            if (item.nutrientInfoMaster.officialName == 'proteinLabel') {
                              description = AppLocalizations.of(context)!.protein;
                            }
                            if (item.nutrientInfoMaster.officialName == 'carbsAvailable') {
                              description = AppLocalizations.of(context)!.carbohydrates;
                            }
                            if (item.nutrientInfoMaster.officialName == 'fatTotal') {
                              description = AppLocalizations.of(context)!.fat;
                            }
                            return MacroNutrientDetailWidget(nutrientsModel: item, description: description,);
                          }),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                ),
              ],
            ),
      ),
    );
  }
}
