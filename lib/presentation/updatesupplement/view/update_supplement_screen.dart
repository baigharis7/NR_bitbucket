import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/bloc/update_supplement_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/item_title_card.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/supplement_item_widget.dart';
import '../../../infrastructure/utils/constants.dart';

class UpdateSupplementScreen extends StatefulWidget {
  static const routeName = '/update_supplement_screen';
  const UpdateSupplementScreen({super.key});

  @override
  State<UpdateSupplementScreen> createState() => _UpdateSupplementFavoriteState();
}

class _UpdateSupplementFavoriteState extends State<UpdateSupplementScreen> {
  late UpdateSupplementBloc updateSupplementBloc;
  final _scrollController = ScrollController();
  FocusNode _supplementFocusInputController = FocusNode();
  bool _showValidation = false;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    updateSupplementBloc = BlocProvider.of<UpdateSupplementBloc>(context);
    updateSupplementBloc.add(InitializationUpdateSupplementEvent());

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        if (arguments is SupplementSimple) {
          updateSupplementBloc.add(SupplementFromArguments(supplementSimple: arguments));
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: updateSupplementBloc,
      child: BlocConsumer<UpdateSupplementBloc, UpdateSupplementState>(
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
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.paddingSmall,
                      vertical: Dimens.paddingLarge,
                    ),
                    child: Column(children: [
                      ScreenTopBar(
                        selectedDate: null,
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: Dimens.height12),
                      HeaderAddItemCardSection(
                        title: AppLocalizations.of(context)!.update + ' ' + AppLocalizations.of(context)!.supplement,
                        image: 'assets/images/supplement.png',
                        searchHintText: AppLocalizations.of(context)!.search_supplement_hint,
                        items: state.supplementsInfo?.data.map((element) => element.translate(context)).toList(),
                        onFocusNodeCreated: (node) => _supplementFocusInputController = node,
                        onItemSelect: (supplementName, focus) {
                          _supplementFocusInputController = focus;
                          focus.unfocus();
                          final supplement = NutritionUtils.findSupplementByName(state.supplementsInfo?.data ?? [], supplementName, context);
                          updateSupplementBloc.add(AddSupplementInfoUpdateSupplementEvent(nutriInfo: NutriInfo(id: supplement.id, unit: supplement.unit, amount: 0)));
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                      ),
                      if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) ...[
                        const SizedBox(height: Dimens.height12),
                        // Title card with favorite/routine toggles
                        ItemTitleCard(
                          name: state.supplementObj?.name,
                          onUpdateName: (name) => updateSupplementBloc.add(UpdateNameSupplementUpdateSupplementEvent(name: name)),
                          isFavorite: state.supplementObj?.isFavorite ?? false,
                          onToggleFavorite: () {
                            if (state.supplementObj?.isFavorite != true) {
                              if (state.supplementObj?.isRoutine == true) updateSupplementBloc.add(UpdateIsRoutineUpdateSupplementEvent(isRoutine: false));
                              updateSupplementBloc.add(UpdateIsFavoriteUpdateSupplementEvent(isFavorite: true));
                            } else {
                              updateSupplementBloc.add(UpdateIsFavoriteUpdateSupplementEvent(isFavorite: false));
                            }
                          },
                          isRoutine: state.supplementObj?.isRoutine ?? false,
                          onToggleRoutine: () {
                            if (state.supplementObj?.isRoutine != true) {
                              if (state.supplementObj?.isFavorite == true) updateSupplementBloc.add(UpdateIsFavoriteUpdateSupplementEvent(isFavorite: false));
                              updateSupplementBloc.add(UpdateIsRoutineUpdateSupplementEvent(isRoutine: true));
                            } else {
                              updateSupplementBloc.add(UpdateIsRoutineUpdateSupplementEvent(isRoutine: false));
                            }
                          },
                          itemCount: state.supplementObj!.info.orEmpty().length,
                          scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.supplementObj?.scheduleTime),
                          onUpdateTime: (scheduleTime) => updateSupplementBloc.add(UpdateTimeOfDaySupplementUpdateSupplementEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                          daysOfWeek: state.supplementObj?.daysOfWeek.orEmpty(),
                          onUpdateDayOfWeek: (weekDay) => updateSupplementBloc.add(UpdateDaysOfWeekSupplementUpdateSupplementEvent(weekDay: weekDay)),
                          isEdit: true,
                        ),
                        ...state.supplementObj!.info.orEmpty().asMap().entries.map((entry) {
                          final index = entry.key;
                          final nutriInfo = entry.value;
                          while (_itemKeys.length <= index) { _itemKeys.add(GlobalKey()); }
                          return SupplementItemWidget(
                              key: _itemKeys[index],
                              title: NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], nutriInfo?.id ?? -1)?.translate(context) ?? '',
                              amount: nutriInfo?.amount == 0 ? '' : nutriInfo?.amount.toString() ?? '',
                              units: nutriInfo != null ? [nutriInfo.unit] : [],
                              unit: nutriInfo?.unit,
                              onChangeAmount: (amount) {
                                nutriInfo?.amount = amount.isEmpty ? 0 : int.parse(amount);
                                updateSupplementBloc.add(UpdateAmountSupplementInfoUpdateSupplementEvent(nutriInfo: nutriInfo!));
                              },
                              onRemoveItem: () => updateSupplementBloc.add(RemoveSupplementInfoUpdateSupplementEvent(nutriInfo: nutriInfo!, isGoBack: () => Navigator.pop(context))),
                              showValidation: _showValidation,
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
                                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                _supplementFocusInputController.requestFocus();
                              },
                              title: Text(AppLocalizations.of(context)!.add_more),
                              trailing: const Icon(Icons.add_circle, color: AppColors.yellowishGreen),
                            ),
                          ),
                        ),
                      ],
                    ],
                    ),
                  ),
                      ),
                      if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.marginSmall),
                        child: GeneralButton(
                          onTap: () {
                            final hasErrors = state.supplementObj?.info.orEmpty().any((n) => n.amount == 0) ?? false;
                            if (hasErrors) {
                              setState(() { _showValidation = true; });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final items = state.supplementObj?.info.orEmpty() ?? [];
                                for (int i = 0; i < items.length; i++) {
                                  if (items[i].amount == 0) {
                                    if (i < _itemKeys.length && _itemKeys[i].currentContext != null) {
                                      Scrollable.ensureVisible(_itemKeys[i].currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                    }
                                    break;
                                  }
                                }
                              });
                              return;
                            }
                            setState(() { _showValidation = false; });
                            if (state.supplementObj!.name.isNotEmptyOrNull()) {
                              updateSupplementBloc.add(SavingUpdateSupplement(onFinish: () => Navigator.pop(context)));
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