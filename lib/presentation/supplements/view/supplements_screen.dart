import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/bloc/supplements_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/view/supplements_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/supplement_item_widget.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../common/view/loading_screen.dart';
import '../../updatesupplement/view/update_supplement_screen.dart';
import '../../widgets/dash_title_widget.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/item_routine_widget.dart';

class SupplementsScreen extends StatefulWidget {
  static const routeName = '/supplements_screen';

  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  late SupplementsBloc supplementsBloc;

  @override
  void initState() {
    supplementsBloc = BlocProvider.of<SupplementsBloc>(context);
    supplementsBloc.add(InitializationSupplementsAction());

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        if (arguments is SupplementSimple) {
          // supplementsBloc.state.screenTitle = AppLocalizations.of(context)!.update + ' ' + AppLocalizations.of(context)!.supplement;
          supplementsBloc.add(UpdateScreenTitle(screenTitle: AppLocalizations.of(context)!.update + ' ' + AppLocalizations.of(context)!.supplement));
          supplementsBloc.add(GetSupplementFromNavAction(supplementSimple: arguments));
        }
      }
    });

    super.initState();
  }

  void _showConfirmationDialog({String? message, required BuildContext context, required Function onDismiss}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: message ?? AppLocalizations.of(context)!.supplement_event_successfully_saved),
    ),).then((value) {
      onDismiss.call();
    }
    );
  }

  Future<void> showRoutineTimeDialog({
    Function? onNameChange,
    required Function onTimeChanged,
    required Function(int) onChangeWeekDays,
    required Function(bool) onFavoriteChange,
    required Function(bool) onChangeCreateRoutine,
    String? name,
    required List<int>? daysOfWeek,
    required TimeOfDay? scheduleTime,
    required bool? isFavorite,
    required bool? isCreateRoutine,
    required int itemsLength,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ItemRoutineWidget(
        onNameChange: (name) => onNameChange?.call(name),
        onTimeChange: (pickedTime) => onTimeChanged.call(pickedTime),
        onChangeWeekDays: (weekDay) => onChangeWeekDays.call(weekDay),
        name: name,
        daysOfWeek: daysOfWeek,
        scheduleTime: scheduleTime,
        isFavorite: isFavorite,
        isCreateRoutine: isCreateRoutine,
        onFavoriteChange: (value) => onFavoriteChange.call(value),
        onChangeCreateRoutine: (value) => onChangeCreateRoutine.call(value),
        itemsLength: itemsLength,
      ),
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: supplementsBloc,
      child: BlocConsumer<SupplementsBloc, SupplementsState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }

          if (state.onError != null) {
            showErrorSnackBar(ctx, resolveError(context, state.onError!));
          }
        },
        builder: (context, state) => Stack(
          children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                    Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                    child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: Column(
                        children: [
                          DatePickerBar(
                            selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.supplementObj?.eventDate),
                            onChangeDate: (dateTime) => supplementsBloc.add(UpdateDateSupplementsAction(dateTime: dateTime)),
                          ),
                          const SizedBox(height: Dimens.height12),
                          HeaderAddItemCardSection(
                            onBackTap: () => Navigator.pop(context),
                            title: state.screenTitle ?? (AppLocalizations.of(context)!.add + ' ' + AppLocalizations.of(context)!.supplement),
                            image: 'assets/images/supplement.png',
                            items: state.supplementsInfo?.data.map((element) => element.translate(context)).toList(),
                            onItemSelect: (supplementName, focus) {
                              // focus.unfocus();
                              final supplement = NutritionUtils.findSupplementByName(state.supplementsInfo?.data ?? [], supplementName, context);
                              supplementsBloc.add(AddSupplementInfoSupplementsAction(nutriInfo: NutriInfo(id: supplement.id, unit: supplement.unit, amount: 0)));
                            },
                          ),
                        ],
                      ),
                    ),
                    if ((state.userProfile?.objectives?.any((element) => element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) && state.supplementObj?.info?.orEmpty().isEmpty == true) Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: Column(children: [
                        const SizedBox(height: Dimens.height12),
                        Container(
                          padding: const EdgeInsets.all(Dimens.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.white70Percent,
                            borderRadius: BorderRadius.circular(Dimens.border11),
                          ),
                          child: Column(children: [
                            ListTile(
                              leading: Image.asset('assets/images/goal_objectives.png', height: Dimens.height32),
                              visualDensity: VisualDensity.compact,
                              title: Text(AppLocalizations.of(context)!.related_objectives,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: Dimens.fontSize17, color: AppColors.peacockBlue),),
                              trailing: Image.asset('assets/images/info.png', height: Dimens.heightXSmall, color: AppColors.peacockBlue),
                            ),
                            if (state.userProfile?.objectives?.contains(Constants.REDUCE_RISK_OF_INJURY) ?? false) ItemInfoCard(
                              title: AppLocalizations.of(context)!.creatine,
                              leadingIconSize: Dimens.height25,
                              trailingSrc: 'assets/icon/add_icon.png',
                              trailingTap: () => supplementsBloc.add(FinishSupplementFavoriteSupplementsEvent(
                                  supplement: SupplementSimple(info: [NutriInfo(id: Constants.CREATINE, unit: 'mg', amount: (0.08 * (state.userProfile?.physicalCharacteristics?.weight ?? 0)).toInt())]),
                                  onFinish: () => _showConfirmationDialog(
                                    message: AppLocalizations.of(context)!.supplement_event_successfully_saved,
                                    context: context,
                                    onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                  ),),),
                              subtitle: '${(0.08 * (state.userProfile?.physicalCharacteristics?.weight ?? 0)).toInt()} mg',
                              leadingSrc: 'assets/images/goal_objectives.png',
                              leadingTap: () {},
                              beforeTrailingSrc: 'assets/icon/edit_icon.png',
                              beforeTrailingTap: () {
                                supplementsBloc.state.supplementObj?.isRoutine = true;
                                supplementsBloc.add(AddSupplementInfoSupplementsAction(
                                    nutriInfo: NutriInfo(id: Constants.CREATINE, unit: 'mg', amount: (0.08 * (state.userProfile?.physicalCharacteristics?.weight ?? 0)).toInt()),
                                ),);
                              },
                            ),
                            if (state.userProfile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) ItemInfoCard(
                              title: AppLocalizations.of(context)!.collagen,
                              leadingIconSize: Dimens.height25,
                              trailingSrc: 'assets/icon/add_icon.png',
                              trailingTap: () => supplementsBloc.add(FinishSupplementFavoriteSupplementsEvent(
                                  supplement: SupplementSimple(info: [NutriInfo(id: Constants.COLLAGEN, unit: 'mg', amount: 10)]),
                                  onFinish: () => _showConfirmationDialog(
                                      message: AppLocalizations.of(context)!.supplement_event_successfully_saved,
                                      context: context,
                                      onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                  ),),),
                              subtitle: '10 mg',
                              leadingSrc: 'assets/images/goal_objectives.png',
                              leadingTap: () {},
                              beforeTrailingSrc: 'assets/icon/edit_icon.png',
                              beforeTrailingTap: () {
                                supplementsBloc.state.supplementObj?.isRoutine = true;
                                supplementsBloc.add(AddSupplementInfoSupplementsAction(nutriInfo: NutriInfo(id: Constants.COLLAGEN, unit: 'mg', amount: 10)));
                              },
                            ),
                          ],),
                        ),
                      ],),
                    ),
                    if (state.supplementObj?.info?.orEmpty().isEmpty == true && state.supplementFavorites.orEmpty().isNotEmpty == true) Column(children: [
                      const SizedBox(height: Dimens.height12),
                      DashTitleWidget(title: '${AppLocalizations.of(context)!.favorites} - ${AppLocalizations.of(context)!.supplement}'),
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: state.supplementFavorites?.length,
                        itemBuilder: (context, index) {
                          final supplementFavorite = state.supplementFavorites.orEmpty()[index];
                          final itemName = supplementFavorite.name ?? NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], supplementFavorite.info![0].id ?? -1).translate(context);
                          return ItemInfoCard(
                            title: itemName,
                            trailingSrc: 'assets/icon/add_icon.png',
                            trailingTap: () => supplementsBloc.add(FinishSupplementFavoriteSupplementsEvent(
                                supplement: supplementFavorite,
                                onFinish: () => _showConfirmationDialog(
                                  message: AppLocalizations.of(context)!.supplement_event_successfully_saved,
                                    context: context,
                                    onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                ),),),
                            subtitle: supplementFavorite.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${supplementFavorite.info![0].amount.toString()} ${supplementFavorite.info![0].unit}.',
                            leadingSrc: 'assets/images/favorite_icon.png',
                            leadingTap: () {},
                            beforeTrailingSrc: 'assets/icon/edit_icon.png',
                            beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSupplementScreen.routeName, arguments: supplementFavorite).then((value) => supplementsBloc.add(InitializationSupplementsAction())),
                          );
                        },
                      ),
                    ],),
                    if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: state.supplementObj?.info?.orEmpty().length,
                            itemBuilder: (context, index) {
                              final nutriInfo = state.supplementObj?.info.orEmpty()[index];
                              return SupplementItemWidget(
                                title: NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], nutriInfo?.id ?? -1).translate(context),
                                amount: nutriInfo?.amount == 0 ? '' : nutriInfo?.amount.toString() ?? '',
                                units: nutriInfo != null ? [nutriInfo.unit] : [],
                                unit: nutriInfo?.unit,
                                onChangeAmount: (amount) {
                                  nutriInfo?.amount = amount.isEmpty ? 0 : int.parse(amount);
                                  supplementsBloc.add(UpdateAmountSupplementsAction(nutriInfo: nutriInfo!));
                                },
                                onRemoveItem: () => supplementsBloc.add(RemoveSupplementInfoSupplementsAction(nutriInfo: nutriInfo!, isGoBack: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName))),
                              );
                            },
                          ),
                          if (state.isEdit != true) const SizedBox(height: Dimens.height32),
                          if (state.isEdit != true) SizedBox(
                            width: Dimens.widthLarge,
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15),),
                              tileColor: AppColors.floralWhite,
                              onTap: () => showRoutineTimeDialog(
                                onNameChange: (name) => supplementsBloc.add(UpdateNameSupplementsEvent(name: name)),
                                onTimeChanged: (time) => supplementsBloc.add(UpdateTimeOfDaySupplementsEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(time))),
                                onChangeWeekDays: (weekDay) => supplementsBloc.add(UpdateDaysOfWeekSupplementsEvent(weekDay: weekDay)),
                                onFavoriteChange: (value) => supplementsBloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: value)),
                                onChangeCreateRoutine: (value) => supplementsBloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: value)),
                                name: state.supplementObj?.name,
                                daysOfWeek: state.supplementObj?.daysOfWeek,
                                scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.supplementObj?.scheduleTime),
                                isFavorite: state.supplementObj?.isFavorite,
                                isCreateRoutine: state.supplementObj?.isRoutine,
                                itemsLength: state.supplementObj?.info?.length ?? 0,
                              ),
                              title: Text(AppLocalizations.of(context)!.add_more_options),
                              trailing: const Icon(Icons.radio_button_checked, color: AppColors.yellowishGreen),
                            ),
                          ),
                          const SizedBox(height: Dimens.height32),
                          GeneralButton(
                            onTap: () {
                              if (state.supplementObj!.info.orEmpty().length == 1 && (state.supplementObj?.name.isEmptyOrNull() == true)) {
                                final name = NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], state.supplementObj?.info.orEmpty()[0].id ?? -1).translate(context);
                                state.supplementObj?.name = name;
                                // supplementsBloc.add(UpdateNameSupplementsEvent(name: name));
                              }

                              if (state.supplementObj!.info.orEmpty().length > 1 && (state.supplementObj?.name.isEmptyOrNull() == true)) {
                                showRoutineTimeDialog(
                                  onNameChange: (name) => supplementsBloc.add(UpdateNameSupplementsEvent(name: name)),
                                  onTimeChanged: (time) => supplementsBloc.add(UpdateTimeOfDaySupplementsEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(time))),
                                  onChangeWeekDays: (weekDay) => supplementsBloc.add(UpdateDaysOfWeekSupplementsEvent(weekDay: weekDay)),
                                  onFavoriteChange: (value) => supplementsBloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: value)),
                                  onChangeCreateRoutine: (value) => supplementsBloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: value)),
                                  name: state.supplementObj?.name,
                                  daysOfWeek: state.supplementObj?.daysOfWeek,
                                  scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.supplementObj?.scheduleTime),
                                  isFavorite: state.supplementObj?.isFavorite,
                                  isCreateRoutine: state.supplementObj?.isRoutine,
                                  itemsLength: state.supplementObj?.info?.length ?? 0,
                                );
                              }

                              if (state.supplementObj!.name.isNotEmptyOrNull()) {
                                if (state.supplementObj?.info.orEmpty().isEmpty == true) return;

                                if (state.supplementObj?.isFavorite == true) {
                                  supplementsBloc.add(FinishSupplementFavorite(onFinish: () => _showConfirmationDialog(
                                    message: AppLocalizations.of(context)!.supplement_favorite_successfully_saved,
                                    context: context,
                                    onDismiss: () {},
                                  ),),);
                                } else if (state.supplementObj?.isRoutine == true) {
                                  if (state.supplementObj?.daysOfWeek?.isEmpty == true || state.supplementObj?.scheduleTime.isEmptyOrNull() == true) {
                                    ToastHelper().showToast(text: AppLocalizations.of(context)!.routine_time_day_error);
                                    return;
                                  }
                                  supplementsBloc.add(FinishSupplementRoutineSupplementsEvent(onFinish: () => _showConfirmationDialog(
                                    message: AppLocalizations.of(context)!.supplement_routine_successfully_saved,
                                    context: context,
                                    onDismiss: () {},
                                  ),),);
                                } else {
                                  supplementsBloc.add(FinishEventSupplementsAction(
                                      onFinish: () => _showConfirmationDialog(
                                        message: AppLocalizations.of(context)!.supplement_event_successfully_saved,
                                        context: context,
                                        onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                      ),),);
                                }
                                // supplementsBloc.add(SavingEventSupplementsAction(onFinish: () => _showConfirmationDialog(context, () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate))));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
