import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/bloc/supplements_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/view/supplements_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_title_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/supplement_item_widget.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../common/view/loading_screen.dart';
import '../../updatesupplement/view/update_supplement_screen.dart';
import '../../widgets/dash_title_widget.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';

class SupplementsScreen extends StatefulWidget {
  static const routeName = '/supplements_screen';

  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  late SupplementsBloc supplementsBloc;
  final ScrollController _scrollController = ScrollController();
  late FocusNode _supplementFocusInputController;
  bool _showValidation = false;

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
        } else if (arguments is Map && arguments['preSelectRoutine'] == true) {
          supplementsBloc.state.supplementObj?.isRoutine = true;
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                body: SafeArea(
                    child: Column(children: [
                      Expanded(
                        child: SingleChildScrollView(
                  controller: _scrollController,
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
                              _supplementFocusInputController = focus;
                              final supplement = NutritionUtils.findSupplementByName(state.supplementsInfo?.data ?? [], supplementName, context);
                              supplementsBloc.add(AddSupplementInfoSupplementsAction(nutriInfo: NutriInfo(id: supplement.id, unit: supplement.unit, amount: 0)));
                              // Auto-scroll to newly added item
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                              // Auto-title logic
                              final currentCount = state.supplementObj!.info.orEmpty().length;
                              if (currentCount == 0) {
                                supplementsBloc.add(UpdateNameSupplementsEvent(name: supplementName));
                              } else if (currentCount == 1) {
                                supplementsBloc.add(UpdateNameSupplementsEvent(name: ''));
                              }
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
                          const SizedBox(height: Dimens.height12),
                          // Title card with favorite/routine toggles
                          ItemTitleCard(
                            name: state.supplementObj?.name,
                            onUpdateName: (name) => supplementsBloc.add(UpdateNameSupplementsEvent(name: name)),
                            isFavorite: state.supplementObj?.isFavorite ?? false,
                            onToggleFavorite: () {
                              if (state.supplementObj?.isFavorite != true) {
                                if (state.supplementObj?.isRoutine == true) supplementsBloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: false));
                                supplementsBloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: true));
                              } else {
                                supplementsBloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: false));
                              }
                            },
                            isRoutine: state.supplementObj?.isRoutine ?? false,
                            onToggleRoutine: () {
                              if (state.supplementObj?.isRoutine != true) {
                                if (state.supplementObj?.isFavorite == true) supplementsBloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: false));
                                supplementsBloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: true));
                              } else {
                                supplementsBloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: false));
                              }
                            },
                            itemCount: state.supplementObj!.info.orEmpty().length,
                            scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.supplementObj?.scheduleTime),
                            onUpdateTime: (scheduleTime) => supplementsBloc.add(UpdateTimeOfDaySupplementsEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                            daysOfWeek: state.supplementObj?.daysOfWeek,
                            onUpdateDayOfWeek: (dayOfWeek) {},
                          ),
                          // Item cards with connector lines
                          ...state.supplementObj!.info.orEmpty().asMap().entries.map((entry) {
                            final index = entry.key;
                            final nutriInfo = entry.value;
                            return Column(
                            children: [
                              SupplementItemWidget(
                                title: NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], nutriInfo?.id ?? -1).translate(context),
                                amount: nutriInfo?.amount == 0 ? '' : nutriInfo?.amount.toString() ?? '',
                                units: nutriInfo != null ? [nutriInfo.unit] : [],
                                unit: nutriInfo?.unit,
                                onChangeAmount: (amount) {
                                  nutriInfo?.amount = amount.isEmpty ? 0 : int.parse(amount);
                                  supplementsBloc.add(UpdateAmountSupplementsAction(nutriInfo: nutriInfo!));
                                },
                                onRemoveItem: () => supplementsBloc.add(RemoveSupplementInfoSupplementsAction(nutriInfo: nutriInfo!, isGoBack: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName))),
                                showValidation: _showValidation,
                              ),
                            ],
                          );
                          }),
                          // Add More button
                          const SizedBox(height: Dimens.marginSmall),
                          Center(
                            child: SizedBox(
                              width: Dimens.widthLarge,
                              height: Dimens.height55,
                              child: ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
                                tileColor: AppColors.floralWhite,
                                onTap: () {
                                  final hasEmptyAmount = state.supplementObj?.info.orEmpty().any((n) => n.amount == 0) ?? false;
                                  if (hasEmptyAmount) {
                                    setState(() { _showValidation = true; });
                                    return;
                                  }
                                  setState(() { _showValidation = false; });
                                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                  _supplementFocusInputController.requestFocus();
                                },
                                title: Text(AppLocalizations.of(context)!.add_more),
                                trailing: const Icon(Icons.add_circle, color: AppColors.yellowishGreen),
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimens.paddingXLarge),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
                ),
                      if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
                        child: GeneralButton(
                          onTap: () {
                            // Validate amounts
                            final hasEmptyAmount = state.supplementObj?.info.orEmpty().any((n) => n.amount == 0) ?? false;
                            if (hasEmptyAmount) {
                              setState(() { _showValidation = true; });
                              return;
                            }
                            // Auto-set title for single items
                            if (state.supplementObj!.info.orEmpty().length == 1 && (state.supplementObj?.name.isEmptyOrNull() == true)) {
                              final name = NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], state.supplementObj?.info.orEmpty()[0].id ?? -1).translate(context);
                              state.supplementObj?.name = name;
                            }

                            // Block save if combo has no name (inline error is shown in the title card)
                            if (state.supplementObj!.info.orEmpty().length > 1 && (state.supplementObj?.name.isEmptyOrNull() == true)) {
                              return;
                            }

                            if (state.supplementObj!.name.isNotEmptyOrNull()) {
                              if (state.supplementObj?.info.orEmpty().isEmpty == true) return;

                              if (state.supplementObj?.isFavorite == true) {
                                supplementsBloc.add(FinishSupplementFavorite(onFinish: () => _showConfirmationDialog(
                                  message: '${AppLocalizations.of(context)!.supplement_event_successfully_saved}\n${AppLocalizations.of(context)!.and}\n${AppLocalizations.of(context)!.supplement_favorite_successfully_saved}',
                                  context: context,
                                  onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                ),),);
                              } else if (state.supplementObj?.isRoutine == true) {
                                if (state.supplementObj?.daysOfWeek?.isEmpty == true || state.supplementObj?.scheduleTime.isEmptyOrNull() == true) {
                                  ToastHelper().showToast(text: AppLocalizations.of(context)!.routine_time_day_error);
                                  return;
                                }
                                supplementsBloc.add(FinishSupplementRoutineSupplementsEvent(onFinish: () => _showConfirmationDialog(
                                  message: '${AppLocalizations.of(context)!.supplement_event_successfully_saved}\n${AppLocalizations.of(context)!.and}\n${AppLocalizations.of(context)!.supplement_routine_successfully_saved}',
                                  context: context,
                                  onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                ),),);
                              } else {
                                supplementsBloc.add(FinishEventSupplementsAction(
                                    onFinish: () => _showConfirmationDialog(
                                      message: AppLocalizations.of(context)!.supplement_event_successfully_saved,
                                      context: context,
                                      onDismiss: () => Navigator.popAndPushNamed(context, SupplementsDetailScreen.routeName, arguments: state.supplementObj?.eventDate),
                                    ),),);
                              }
                            }
                          },
                        ),
                      ),
                    ],
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
