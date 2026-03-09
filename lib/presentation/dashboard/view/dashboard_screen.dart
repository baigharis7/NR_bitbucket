import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/methods_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/barcodescanning/view/bar_code_scanning_screen.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/floating_menu_controller.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/view/energy_balance_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/favorites_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurinedetails/view/feces_urine_tabs.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/view/liquid_summary_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/view/macro_nutrients_detail.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/view/meal_time_details_screen.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/view/weekly_all_nutrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/view/sport_items_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/view/sugar_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/view/supplements_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/NutritionProgressWidget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/card_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dashboard_calendar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/energy_balance_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/liquids_summary_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/micro_nutrients_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrients_dashboard_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/row_sugar_fiber.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/sugar_intake_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/swith_with_function_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/vertical_nutrient_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/water_intake_wigdet.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/water_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/week_calendar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_rda_nutrients_dashboard_widget.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../../infrastructure/utils/string_utils.dart';
import '../../fecesurine/view/feces_urine_tab_holder.dart';
import '../../fiber_detail/view/fiber_detail_Screen.dart';
import '../../login/view/login_screen.dart';
import '../../widgets/NutrientDetailWidget.dart';
import '../../widgets/ani_nutri_progress_bar_widget.dart';
import '../../widgets/dash_title_widget.dart';
import '../../widgets/data_bottom_sheet_widget.dart';
import 'package:sprintf/sprintf.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  // StepCount? _stepCountValue;
  DateTime? selectedDateTime;
  late DashboardBloc bloc;
  bool isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  StreamSubscription<DateTime>? _midnightSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.state.isShowDialog = false;
    bloc.add(InitializeState());
    selectedDateTime = DateTime.now();

    MidnightService.instance.start();
    _midnightSubscription = MidnightService.instance.stream.listen((newDate) {
      setState(() {
        selectedDateTime = newDate;
      });
      bloc.add(InitializeState(dateTime: newDate));
    });

    _controller = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _midnightSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MidnightService.instance.checkNow();
      FcmService.instance.triggerSync();
      context.read<HealthSyncBloc>().add(HealthSyncManualTrigger());
    }
  }

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  List<Map<String, dynamic>> getMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      ...MealTime.getAllMealTimes().map((e) => {'label': e.name, 'id': e.id, 'icon': 'assets/images/meal_time_${e.id.orZero()}.png', 'onTap': () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: FoodArgumentsModel(mealTime: e, selectedDateTime: selectedDateTime ?? DateTime.now()))}),
      // {'label': 'Actividad física', 'icon': Icons.fitness_center},
      {'label': AppLocalizations.of(context)!.supplements, 'icon': 'assets/images/supplement.png', 'onTap': () => Navigator.pushNamed(context, SupplementsScreen.routeName)},
      {'label': AppLocalizations.of(context)!.physical_activity, 'icon': 'assets/images/sport.png', 'onTap': () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: selectedDateTime)},
      {'label': AppLocalizations.of(context)!.faeces_urine, 'icon': 'assets/images/feces_urine.png', 'onTap': () => Navigator.pushNamed(context, FecesUrineTabs.routeName)},
    ];

    return menuItems;
  }

  Future<void> _updateDataDialog({required Function onUpdateClick}) async {
    await showModalBottomSheet(showDragHandle: true, isDismissible: false, enableDrag: false, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimens.borderXLarge), topRight: Radius.circular(Dimens.borderXLarge))),context: context,
      builder: (context) => DataBottomSheetWidget(
          icon: const Icon(Icons.info_outlined, color: AppColors.mountainMeadow, size: 45),
          title: AppLocalizations.of(context)!.update_your_data,
          description: AppLocalizations.of(context)!.update_desc,
          successButtonText: AppLocalizations.of(context)!.update_data,
        successButtonClick: () => onUpdateClick.call(),
        cancelButtonText: AppLocalizations.of(context)!.cancel,
        cancelButtonClick: () => onUpdateClick.call(),
      ),);
  }
  
  Future<void> _workOutDialog({required int tim, Function? onFinish}) async {
    await showModalBottomSheet(showDragHandle: true, isDismissible: false, enableDrag: false, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimens.borderXLarge), topRight: Radius.circular(Dimens.borderXLarge))),
      context: context, builder: (context) => DataBottomSheetWidget(
        icon: const Icon(Icons.info_outlined, color: AppColors.mountainMeadow, size: 45),
        title: sprintf(AppLocalizations.of(context)!.workout_dialog_title, [tim]),
      description: AppLocalizations.of(context)!.workout_dialog_desc,
    ),
    ).then((value) => onFinish?.call());
  }

  Future<void> _afterWorkoutDialog({Function? onFinish}) async {
    await showModalBottomSheet(showDragHandle: true, isDismissible: false, enableDrag: false, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimens.borderXLarge), topRight: Radius.circular(Dimens.borderXLarge))),
      context: context, builder: (context) => DataBottomSheetWidget(
        icon: const Icon(Icons.info_outlined, color: AppColors.mountainMeadow, size: 45),
        title: AppLocalizations.of(context)!.after_workout_dialog_title,
        description: AppLocalizations.of(context)!.after_workout_dialog_desc,
      ),
    ).then((value) => onFinish?.call());
  }

  Future<void> _improveRecoveryDialog({Function? onFinish}) async {
    await showModalBottomSheet(showDragHandle: true, isDismissible: false, enableDrag: false, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimens.borderXLarge), topRight: Radius.circular(Dimens.borderXLarge))),
      context: context, builder: (context) => DataBottomSheetWidget(
        icon: const Icon(Icons.info_outlined, color: AppColors.mountainMeadow, size: 45),
        title: AppLocalizations.of(context)!.improve_recovery_title,
        description: AppLocalizations.of(context)!.improve_recovery_desc,
      ),
    ).then((value) => onFinish?.call());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.recal_nutrients,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
          if ((state.isUpdatedDataNeeded ?? false) && state.isLoading == false) _updateDataDialog(onUpdateClick: () => bloc.add(LogoutFromAppEventAction(onFinish: () => Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false,))));
          if (state.foundedRoutineRemainingHours.orZero() > 0 && state.foundedRoutineRemainingHours.orZero() <= 3 && state.profile?.objectives?.contains(Constants.IMPROVE_SPORT_PERFORMANCE) == true && state.isLoading == false && (state.isShowDialog ?? false) == false) _workOutDialog(tim: state.foundedRoutineRemainingHours!, onFinish: () => bloc.add(ShowDialogEventAction()));
          if (state.foundedRoutineRemainingHours == 0 && state.profile?.objectives?.contains(Constants.IMPROVE_SPORT_PERFORMANCE) == true && state.isLoading == false && (state.isShowDialog ?? false) == false) _afterWorkoutDialog(onFinish: () => bloc.add(ShowDialogEventAction()));
          if (state.profile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) == true && state.isLoading == false && (state.isShowDialog ?? false) == false && bloc.isNeedToShowModel(state.sportInjuryModal)) _improveRecoveryDialog(onFinish: () { bloc.add(ShowDialogEventAction()); bloc.add(SaveHideModelInfo()); });
        },
        builder: (ctx, state) {
          return Stack(children: [
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
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            //   child: Container(
            //     color: Colors.black.withOpacity(0), // Needed to activate the blur
            //   ),
            // ),

            // Foreground content for the user interaction
            Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                elevation: 0.0,
                title: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.hi + ' ',
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize21),
                    ),
                    Text(
                      (state.profile?.commonName ?? '') + '.',
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize21),
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                actions: [
                  // IconButton(
                  //   alignment: Alignment.centerRight,
                  //   visualDensity: VisualDensity.compact,
                  //   onPressed: () => Navigator.pushNamed(context, BarCodeScanningScreen.routeName),
                  //   icon: Image.asset(
                  //     'assets/icon/scanner_icon.png',
                  //     color: Colors.white,
                  //     height: Dimens.height18,
                  //     width: Dimens.height18,
                  //   ),
                  // ),
                  IconButton(
                    alignment: Alignment.centerLeft,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => showDialog(context: context, builder: (context) => SimpleDialog(alignment: Alignment.topCenter,
                      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.padding5Large +5),
                      contentPadding: EdgeInsets.zero,
                      children: [
                        DashboardCalendarWidget(currentLanguage: currentLanguage, focused: selectedDateTime, callGetAllEvents: (day) => bloc.getEventsForDay(day), selectedDateForEventsLoading: (date) {
                          selectedDateTime = date;
                          Navigator.pop(context);
                          bloc.add(InitializeState(dateTime: date, onFinish: () {}));
                        },),
                      ],
                    ),), icon: SvgPicture.asset('assets/svg/calendar.svg',),),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeekCalendarWidget(onDateClick: (date) {
                        selectedDateTime = date;
                        bloc.add(InitializeState(dateTime: date,));
                      }, selectedDateTime: selectedDateTime, callGetAllEvents: (day) => bloc.getEventsForDay(day)),
                      const SizedBox(height: Dimens.heightXSmall),
                      NutritionProgressWidget(energyModel: state.energyModel, nutrientsList: state.macronutrients.orEmpty(), selectedDate: selectedDateTime, sugarAndFiberModel: state.sugarAndFiberModel),
                      // if (state.profile?.sex?.index == SexType.female.index && (state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.menopause.index && state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.withoutPeriod.index)) SwitchDashboardWidget(
                      //     title: AppLocalizations.of(context)!.menstruation,
                      //     currentState: state.isMenstruation ?? false,
                      //     onStateChange: (value) => bloc.add(UpdateMenstruationStateAction(isMenstruation: value)),
                      // ),
                      // SwitchDashboardWidget(
                      //   title: AppLocalizations.of(context)!.cold,
                      //   currentState: state.isCold ?? false,
                      //   onStateChange: (value) => bloc.add(UpdateColdStateAction(isCold: value)),
                      // ),
                      // EnergyBalanceWidget(
                      //   energyModel: state.energyModel,
                      //   screenToMove: () => Navigator.pushNamed(context, EnergyBalanceDetailScreen.routeName, arguments: state.energyModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                      // ),
                      // ExpandableWidget(
                      //     titleClick: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: state.micronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime,))),
                      //     title: AppLocalizations.of(context)!.micronutrients, nutrientsList: state.micronutrients.orEmpty()),
                      // NutrientsDashboardWidget(
                      //   title: AppLocalizations.of(context)!.micronutrients,
                      //   nutrients: state.micronutrients.orEmpty().where((element) => element.upperLimit > 0).toList(),
                      //   isEmpty: false,
                      //   screenToMove: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: state.micronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime,))),
                      // ),
                      // WeeklyRDANutrientsDashboardWidget(
                      //   title: AppLocalizations.of(context)!.weekly_nutrients,
                      //   nutrients: const []/*state.weeklyMicronutrients.orEmpty().take(Constants.DASHBOARD_LIST_SIZE).toList()*/,
                      //   isEmpty: false,
                      //   screenToMove: () => Navigator.pushNamed(context, WeeklyAllNutrientsDetailScreen.routeName, arguments: state.weeklyMicronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                      // ),
                      // NutrientsDashboardWidget(
                      //   title: AppLocalizations.of(context)!.macronutrients,
                      //   nutrients: state.macronutrients.orEmpty(),
                      //   // isEmpty: state.foodEvents.isNull() ? true : state.foodEvents!.isEmpty,
                      //   isEmpty: false,
                      //   screenToMove: () => Navigator.pushNamed(context, MacroNutrientsDetailScreen.routeName, arguments: state.macronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                      // ),
                      MicroNutrientsSection(micronutrients: state.micronutrients.orEmpty(), temporaryMicronutrients: state.temporaryMicronutrients.orEmpty(), filteredNutrientsLess15RDA: state.filteredNutrientsLess15RDA.orEmpty(), objectives: state.profile?.objectives.orEmpty().where((element) => ![Constants.COLD, Constants.DURING_MENSTRUATION, Constants.GAIN_MUSCLE, Constants.LOSE_FAT, Constants.MAINTAIN_WEIGHT].contains(element)).toList(), selectedDate: selectedDateTime),
                      MealTimeSection(
                        foodEvents: state.foodEvents.orEmpty(),
                        totalKcal: state.userKcal.orZero(),
                        selectedDateTime: selectedDateTime!,
                        supplementsCard: MealTimeWidget(
                          name: AppLocalizations.of(context)!.supplements,
                          svg: 'assets/images/supplement.png',
                          onItemClick: () => Navigator.pushNamed(context, SupplementsDetailScreen.routeName, arguments: selectedDateTime),
                          onClick: () => Navigator.pushNamed(context, SupplementsScreen.routeName),
                          compact: true,
                        ),
                      ),
                      WaterIntakeWidget(
                        totalLitersGoal: (state.profile?.physicalCharacteristics?.weight ?? 0) * 0.035,
                        consumedGlasses: EventsHelper().getWaterIntakeAddition(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.foodEvents.orEmpty()) ~/ 0.25,
                        onInfoClick: () => Navigator.pushNamed(context, LiquidSummaryDetailScreen.routeName, arguments: selectedDateTime),
                        onAddWater: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_ADD_WATER_QUANTITY, onFinish: () {})),
                        onRemoveWater: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_REMOVE_WATER_QUANTITY, onFinish: () {})),
                      ),
                      DashTitleWidget(title: AppLocalizations.of(context)!.physical_activity, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20)),
                      MealTimeWidget(
                        name: AppLocalizations.of(context)!.physical_activity,
                        onItemClick: () => Navigator.pushNamed(context, SportItemsScreen.routeName, arguments: selectedDateTime),
                        onClick: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: selectedDateTime),
                        backgroundColor: AppColors.floralWhite, svg: 'assets/images/sport.png',
                      ),
                      DashTitleWidget(title: AppLocalizations.of(context)!.depositions, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20)),
                      MealTimeWidget(
                        name: AppLocalizations.of(context)!.faeces_urine,
                        svg: 'assets/images/feces_urine.png',
                        onItemClick: () => Navigator.pushNamed(context, FecesUrineTabHolder.routeName, arguments: selectedDateTime),
                        onClick: () => Navigator.pushNamed(context, FecesUrineTabs.routeName),
                        backgroundColor: Colors.transparent,
                        backgroundImage: 'assets/images/feces_urine_background.png',
                      ),
                      // ListTile(
                      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border11),),
                      //   tileColor: AppColors.floralWhite,
                      //   onTap: () {
                      //     Navigator.pushNamed(context, FavoritesTabHolder.routeName);
                      //   },
                      //   leading: Image.asset('assets/images/favorite_icon.png',color: Colors.white, height: 21, width: 21),
                      //   title: Text(AppLocalizations.of(context)!.favorites, style: const TextStyle(color: Colors.white)),
                      // ),
                      const SizedBox(height: Dimens.height60),
                      // WaterWidget(),
                      // SizedBox(
                      //   height: 200,
                      //   child: Row(
                      //       children: [
                      //         Expanded(
                      //           flex: 1,
                      //           child: LiquidSummaryWidget(
                      //             quantityTaken: EventsHelper().getWaterIntakeAddition(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.foodEvents.orEmpty()),
                      //             fractionToFill: EventsHelper().getWaterFractionToFillFromEvents(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.foodEvents.orEmpty(), ((state.profile?.physicalCharacteristics?.weight ?? 0) * 0.035)),
                      //             totalWater: ((state.profile?.physicalCharacteristics?.weight ?? 0) * 0.035).toStringAsFixed(2),
                      //             onReloadData: () { /*bloc.add(ReloadWaterInfoAction());*/ },
                      //             screenToMove: () => Navigator.pushNamed(context, LiquidSummaryDetailScreen.routeName, arguments: state.waterEvents).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                      //             addWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_ADD_WATER_QUANTITY, onFinish: () => bloc.add(InitializeState(dateTime: selectedDateTime)))),
                      //             removeWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_REMOVE_WATER_QUANTITY, onFinish: () => bloc.add(InitializeState(dateTime: selectedDateTime)))),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           flex: 1,
                      //           child: Stack(
                      //             children: [
                      //               Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0,), color: Colors.black,), child: Center(child: Text(AppLocalizations.of(context)!.coming_soon, style: const TextStyle(color: Colors.white),),)),
                      //               Opacity(
                      //                 opacity: 0.4,
                      //                 child: Card(
                      //                   child: Column(
                      //                     children: [
                      //                       Container(
                      //                         margin: const EdgeInsets.only(left: Dimens.marginNormal),
                      //                         alignment: Alignment.centerLeft,
                      //                         child: Row(
                      //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                           children: [
                      //                             Text(
                      //                               AppLocalizations.of(context)!.steps,
                      //                               style: const TextStyle(
                      //                                 fontSize: Dimens.fontSizeNormal,
                      //                                 color: Colors.black,
                      //                                 fontWeight: FontWeight.bold,
                      //                               ),
                      //                             ),
                      //                             Container(
                      //                               alignment: Alignment.centerRight,
                      //                               child: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       Container(
                      //                         height: 80,
                      //                         decoration: const BoxDecoration(
                      //                           shape: BoxShape.circle,
                      //                           color: Colors.grey,
                      //                         ),
                      //                         child: const Center(child: Text('0'),),
                      //                       ),
                      //                       Container(
                      //                         margin: const EdgeInsets.only(top: Dimens.marginNormal),
                      //                         child: const Row(
                      //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                           children: [
                      //                             Text(' Km'),
                      //                             Text('98 min'),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       // Text('${_stepCountValue}'),
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //   ),
                      // ),
                      // Card(
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Container(
                      //               alignment: Alignment.centerLeft,
                      //               margin: const EdgeInsets.all(Dimens.marginNormal),
                      //               child: Text(
                      //                 AppLocalizations.of(context)!.sugar,
                      //                 style: const TextStyle(fontWeight: FontWeight.bold),
                      //               ),
                      //             ),
                      //           ),
                      //           IconButton(onPressed: () => Navigator.pushNamed(context, SugarDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                      //         ],
                      //       ),
                      //       Container(
                      //         margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      //         child: Stack(
                      //           alignment: Alignment.bottomCenter,
                      //           children: [
                      //           FillHorizontalBar(fillColor: (state.sugarAndFiberModel?.fractionToFillSugar ?? 0.0) >= 1.0 ? AppColors.errorRed : AppColors.mountainMeadow, fractionToFill: state.sugarAndFiberModel?.fractionToFillSugar ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                      //           Container(
                      //             alignment: Alignment.center,
                      //             margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                      //             child: Text(
                      //                 '${state.sugarAndFiberModel?.totalSugarConsumed ?? 0.0}',
                      //               style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                      //             ),
                      //           ),
                      //         ],),
                      //       ),
                      //       Container(
                      //         margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                      //         alignment: Alignment.centerRight,
                      //         child: Text(
                      //           (state.sugarAndFiberModel?.requiredSugar.toString() ?? '0').appendGram(),
                      //           style: const TextStyle(fontSize: Dimens.fontSizeSmall),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // Card(
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Container(
                      //               alignment: Alignment.centerLeft,
                      //               margin: const EdgeInsets.all(Dimens.marginNormal),
                      //               child: Text(
                      //                 AppLocalizations.of(context)!.fiber,
                      //                 style: const TextStyle(fontWeight: FontWeight.bold),
                      //               ),
                      //             ),
                      //           ),
                      //           IconButton(onPressed: () => Navigator.pushNamed(context, FiberDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                      //         ],
                      //       ),
                      //       Container(
                      //         margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      //         child: Stack(
                      //           alignment: Alignment.bottomCenter,
                      //           children: [
                      //           FillHorizontalBar(fillColor: (state.sugarAndFiberModel?.fractionToFillFiber ?? 0.0) >= 1.0 ? AppColors.errorRed : AppColors.mountainMeadow, fractionToFill: state.sugarAndFiberModel?.fractionToFillFiber ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                      //           Container(
                      //             alignment: Alignment.center,
                      //             margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                      //             child: Text(
                      //               '${state.sugarAndFiberModel?.totalFiberConsumed ?? 0.0}',
                      //               style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                      //             ),
                      //           ),
                      //         ],),
                      //       ),
                      //       Container(
                      //         margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                      //         alignment: Alignment.centerRight,
                      //         child: Text(
                      //           (state.sugarAndFiberModel?.requiredFiber.toString() ?? '0').appendGram(),
                      //           style: const TextStyle(fontSize: Dimens.fontSizeSmall),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // if  (state.profile?.objectives?.any((element) => element ==  Constants.IMPROVE_SPORT_PERFORMANCE || element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) CardWidget(title: AppLocalizations.of(context)!.supplements,
                      //     // children: state.supplements.orEmpty().map((creatine) => NutrientDetailWidget(todayCreatine: creatine, onMinusClick: (supplement) {}, onPlusClick: (supplement) {}),).toList()),
                      //     children: [
                      //       if  (state.profile?.objectives?.any((element) => element ==  Constants.IMPROVE_SPORT_PERFORMANCE || element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) NutrientDetailWidget(todayCreatine: state.todayCreatineSupplement, onMinusClick: (supplement) => bloc.add(UploadCreatineEventAction(value: -2, supplementInfo: supplement,)), onPlusClick: (supplement) => bloc.add(UploadCreatineEventAction(value: 2, supplementInfo: supplement,))),
                      //       if  (state.profile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) NutrientDetailWidget(todayCreatine: state.todayCollagenSupplement, onMinusClick: (supplement) => bloc.add(UploadCollagenEventAction(value: -2, supplementInfo: supplement,)), onPlusClick: (supplement) => bloc.add(UploadCollagenEventAction(value: 2, supplementInfo: supplement,))),
                      //     ],
                      // ),
                      // if (state.showCard != null && state.showCard!) Positioned(
                      //   top: 100,
                      //   width: mediaQuerySize.width,
                      //   child: ExplainingCardsHelper().getExplainingCardWithId(
                      //     context: context,
                      //     explainingCardId: ExplainingCardRefs.dashboard.index,
                      //     onHideCard: () => bloc.add(HideCardAction()),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD,),
              floatingActionButton: FloatingActionButton(
                onPressed: () => FloatingMenuController().show(context, getMenuItems(context)),
                backgroundColor: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.greenCyan, AppColors.bluishGreen], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7])),
                  child: RotationTransition(
                    turns: _animation,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              // CustomBottomAppBar(initStateCallback: () => bloc.add(InitializeState())),
              // resizeToAvoidBottomInset: true,
              // floatingActionButton: FloatingActionButton(
              //   elevation: 2.0,
              //   backgroundColor: Colors.white,
              //   onPressed: () {},
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
          ],);
        },
      ),
    );
  }

}