import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
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
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/view/weekly_all_nutrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/view/sugar_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/card_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dashboard_calendar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/energy_balance_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/liquids_summary_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrients_dashboard_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/swith_with_function_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_rda_nutrients_dashboard_widget.dart';

import '../../../infrastructure/utils/constants.dart';
import '../../fiber_detail/view/fiber_detail_Screen.dart';
import '../../login/view/login_screen.dart';
import '../../widgets/NutrientDetailWidget.dart';
import '../../widgets/data_bottom_sheet_widget.dart';
import 'package:sprintf/sprintf.dart';
import 'package:upgrader/upgrader.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {

  // StepCount? _stepCountValue;
  DateTime? selectedDateTime;
  late DashboardBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.state.isShowDialog = false;
    bloc.add(InitializeState());

    // RequestPermissionManager(PermissionType.activityRecognition)
    //     .onPermissionDenied(() {
    //       ToastHelper().showToast(backgroundColor: AppColors.mountainMeadow, textColor: Colors.white, text: 'You\'ve to give permission to use physical activity feature' );
    // }).onPermissionGranted(() {
    //   PedometerManager.init().onData((stepCount) {
    //     setState(() {
    //       _stepCountValue = stepCount;
    //     });
    //   }).onError((error) {
    //     ToastHelper().showToast(text: '$error');
    //   }).execute();
    // }).onPermissionPermanentlyDenied(() {
    //   showErrorSnackBar(context, 'Can\'t Access Activity Recognition', actionLabel: 'Open App Settings', action: () => openAppSettings());
    // }).execute();

    super.initState();
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
      child: SafeArea(
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
            if (state.profile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) == true && state.isLoading == false && (state.isShowDialog ?? false) == false) _improveRecoveryDialog(onFinish: () => bloc.add(ShowDialogEventAction()));
          },
          builder: (ctx, state) {
            return UpgradeAlert(
              canDismissDialog: false,
              showLater: true,
              showIgnore: false,
              showReleaseNotes: false,
              shouldPopScope: () => false,
              dialogStyle: Platform.isIOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
              upgrader: Upgrader(
                countryCode: 'PK',
                debugLogging: true,
              ),
              child: Scaffold(
                appBar: AppBar(
                  title: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: Dimens.marginNormal,),
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        AppLocalizations.of(context)!.welcome,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeLarge,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.white,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName),
                      iconSize: 35.0,
                      icon: Image.asset(
                        'assets/icon/profile_icon.png',
                        color: Colors.black,
                        height: 29,
                        width: 29,
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(Dimens.heightSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // IconButton(onPressed: () => Navigator.pushNamed(context, WeeklyDashboardDetailScreen.routeName).then((value) => bloc.add(InitializeState())), icon: const Icon(Icons.arrow_drop_down_circle_outlined)),
                        IconButton(onPressed: () => showDialog(context: context, builder: (context) => SimpleDialog(alignment: Alignment.topCenter,
                          insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.padding5Large +5),
                          contentPadding: EdgeInsets.zero,
                          children: [
                            DashboardCalendarWidget(currentLanguage: currentLanguage, focused: selectedDateTime, callGetAllEvents: (day) => bloc.getEventsForDay(day), selectedDateForEventsLoading: (date) {
                              selectedDateTime = date;
                              bloc.add(InitializeState(dateTime: date, onFinish: () => Navigator.pop(context)));
                            }),
                          ],
                        ),), icon: const Icon(Icons.arrow_drop_down_circle_outlined)),
                        Text(bloc.getTodayMessage(AppLocalizations.of(context)!.today, Localizations.localeOf(context).languageCode),),
                      ],
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          if (state.profile?.sex?.index == SexType.female.index && (state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.menopause.index && state.profile?.femaleCharacteristics?.menstruation?.regularity != MenstruationRegularity.withoutPeriod.index)) SwitchDashboardWidget(
                              title: AppLocalizations.of(context)!.menstruation,
                              currentState: state.isMenstruation ?? false,
                              onStateChange: (value) => bloc.add(UpdateMenstruationStateAction(isMenstruation: value)),
                          ),
                          SwitchDashboardWidget(
                            title: AppLocalizations.of(context)!.cold,
                            currentState: state.isCold ?? false,
                            onStateChange: (value) => bloc.add(UpdateColdStateAction(isCold: value)),
                          ),
                          EnergyBalanceWidget(
                            energyModel: state.energyModel,
                            screenToMove: () => Navigator.pushNamed(context, EnergyBalanceDetailScreen.routeName, arguments: state.energyModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                          ),
                          // ExpandableWidget(
                          //     titleClick: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: state.micronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime,))),
                          //     title: AppLocalizations.of(context)!.micronutrients, nutrientsList: state.micronutrients.orEmpty()),
                          NutrientsDashboardWidget(
                            title: AppLocalizations.of(context)!.micronutrients,
                            nutrients: state.micronutrients.orEmpty().toList(),
                            isEmpty: false,
                            screenToMove: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: state.micronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime,))),
                          ),
                          WeeklyRDANutrientsDashboardWidget(
                            title: AppLocalizations.of(context)!.weekly_nutrients,
                            nutrients: const []/*state.weeklyMicronutrients.orEmpty().take(Constants.DASHBOARD_LIST_SIZE).toList()*/,
                            isEmpty: false,
                            screenToMove: () => Navigator.pushNamed(context, WeeklyAllNutrientsDetailScreen.routeName, arguments: state.weeklyMicronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                          ),
                          NutrientsDashboardWidget(
                            title: AppLocalizations.of(context)!.macronutrients,
                            nutrients: state.macronutrients.orEmpty(),
                            // isEmpty: state.foodEvents.isNull() ? true : state.foodEvents!.isEmpty,
                            isEmpty: false,
                            screenToMove: () => Navigator.pushNamed(context, MacroNutrientsDetailScreen.routeName, arguments: state.macronutrients.orEmpty()).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                          ),
                          SizedBox(
                            height: 200,
                            child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: LiquidSummaryWidget(
                                      quantityTaken: EventsHelper().getWaterIntakeAddition(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.foodEvents.orEmpty()),
                                      fractionToFill: EventsHelper().getWaterFractionToFillFromEvents(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.foodEvents.orEmpty(), ((state.profile?.physicalCharacteristics?.weight ?? 0) * 0.035)),
                                      totalWater: ((state.profile?.physicalCharacteristics?.weight ?? 0) * 0.035).toStringAsFixed(2),
                                      onReloadData: () { /*bloc.add(ReloadWaterInfoAction());*/ },
                                      screenToMove: () => Navigator.pushNamed(context, LiquidSummaryDetailScreen.routeName, arguments: state.waterEvents).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))),
                                      addWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_ADD_WATER_QUANTITY, onFinish: () => bloc.add(InitializeState(dateTime: selectedDateTime)))),
                                      removeWaterCall: () => bloc.add(FinishWaterEventAction(qty: Constants.DEFAULT_REMOVE_WATER_QUANTITY, onFinish: () => bloc.add(InitializeState(dateTime: selectedDateTime)))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Stack(
                                      children: [
                                        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0,), color: Colors.black,), child: Center(child: Text(AppLocalizations.of(context)!.coming_soon, style: const TextStyle(color: Colors.white),),)),
                                        Opacity(
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
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 80,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey,
                                                  ),
                                                  child: const Center(child: Text('0'),),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(top: Dimens.marginNormal),
                                                  child: const Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Text(' Km'),
                                                      Text('98 min'),
                                                    ],
                                                  ),
                                                ),
                                                // Text('${_stepCountValue}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                    IconButton(onPressed: () => Navigator.pushNamed(context, SugarDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                    FillHorizontalBar(fillColor: (state.sugarAndFiberModel?.fractionToFillSugar ?? 0.0) >= 1.0 ? AppColors.errorRed : AppColors.mountainMeadow, fractionToFill: state.sugarAndFiberModel?.fractionToFillSugar ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                                      child: Text(
                                          '${state.sugarAndFiberModel?.totalSugarConsumed ?? 0.0}',
                                        style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                                      ),
                                    ),
                                  ],),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    (state.sugarAndFiberModel?.requiredSugar.toString() ?? '0').appendGram(),
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
                                    IconButton(onPressed: () => Navigator.pushNamed(context, FiberDetailScreen.routeName, arguments: state.sugarAndFiberModel).then((value) => bloc.add(InitializeState(dateTime: selectedDateTime))), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                    FillHorizontalBar(fillColor: (state.sugarAndFiberModel?.fractionToFillFiber ?? 0.0) >= 1.0 ? AppColors.errorRed : AppColors.mountainMeadow, fractionToFill: state.sugarAndFiberModel?.fractionToFillFiber ?? 0.0, backgroundBarColor: AppColors.cardGreen_200),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                                      child: Text(
                                        '${state.sugarAndFiberModel?.totalFiberConsumed ?? 0.0}',
                                        style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                                      ),
                                    ),
                                  ],),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: Dimens.marginSmall, bottom: Dimens.marginNormal),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    (state.sugarAndFiberModel?.requiredFiber.toString() ?? '0').appendGram(),
                                    style: const TextStyle(fontSize: Dimens.fontSizeSmall),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if  (state.profile?.objectives?.any((element) => element ==  Constants.IMPROVE_SPORT_PERFORMANCE || element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) CardWidget(title: AppLocalizations.of(context)!.supplements,
                              // children: state.supplements.orEmpty().map((creatine) => NutrientDetailWidget(todayCreatine: creatine, onMinusClick: (supplement) {}, onPlusClick: (supplement) {}),).toList()),
                              children: [
                                if  (state.profile?.objectives?.any((element) => element ==  Constants.IMPROVE_SPORT_PERFORMANCE || element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) NutrientDetailWidget(todayCreatine: state.todayCreatineSupplement, onMinusClick: (supplement) => bloc.add(UploadCreatineEventAction(value: -2, supplementInfo: supplement,)), onPlusClick: (supplement) => bloc.add(UploadCreatineEventAction(value: 2, supplementInfo: supplement,))),
                                if  (state.profile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) NutrientDetailWidget(todayCreatine: state.todayCollagenSupplement, onMinusClick: (supplement) => bloc.add(UploadCollagenEventAction(value: -2, supplementInfo: supplement,)), onPlusClick: (supplement) => bloc.add(UploadCollagenEventAction(value: 2, supplementInfo: supplement,))),
                              ],
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
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD,)
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
            );
          },
        ),
      ),
    );
  }

}