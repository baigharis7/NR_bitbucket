import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/bloc/update_supplement_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/event_options_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/item_routine_widget.dart';
import '../../widgets/supplement_item_widget.dart';

class UpdateSupplementScreen extends StatefulWidget {
  static const routeName = '/update_supplement_screen';
  const UpdateSupplementScreen({super.key});

  @override
  State<UpdateSupplementScreen> createState() => _UpdateSupplementFavoriteState();
}

class _UpdateSupplementFavoriteState extends State<UpdateSupplementScreen> {
  late UpdateSupplementBloc updateSupplementBloc;
  
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

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingLarge,
                  ),
                  child: Column(children: [
                    HeaderAddItemCardSection(
                      onBackTap: () => Navigator.pop(context),
                      title: AppLocalizations.of(context)!.update + ' ' + AppLocalizations.of(context)!.supplement,
                      image: 'assets/images/supplement.png',
                      items: state.supplementsInfo?.data.map((element) => element.translate(context)).toList(),
                      onItemSelect: (supplementName, focus) {
                        focus.unfocus();
                        final supplement = NutritionUtils.findSupplementByName(state.supplementsInfo?.data ?? [], supplementName, context);
                        updateSupplementBloc.add(AddSupplementInfoUpdateSupplementEvent(nutriInfo: NutriInfo(id: supplement.id, unit: supplement.unit, amount: 0)));
                      },
                    ),
                    if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) const SizedBox(height: Dimens.height12),
                    if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) EventOptionsWidget(
                      name: state.supplementObj?.name,
                      onUpdateName: (name) => updateSupplementBloc.add(UpdateNameSupplementUpdateSupplementEvent(name: name)),
                      daysOfWeek: (state.supplementObj?.isRoutine == true) ? state.supplementObj?.daysOfWeek.orEmpty() : null,
                      onUpdateDayOfWeek: (state.supplementObj?.isRoutine == true) ? (weekDay) => updateSupplementBloc.add(UpdateDaysOfWeekSupplementUpdateSupplementEvent(weekDay: weekDay)) : null,
                      scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.supplementObj?.scheduleTime),
                      onUpdateTime: (state.supplementObj?.isRoutine == true) ? (scheduleTime) => updateSupplementBloc.add(UpdateTimeOfDaySupplementUpdateSupplementEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))): null,
                    ),
                    const SizedBox(height: Dimens.height12),
                    if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) ListView.builder(
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
                            updateSupplementBloc.add(UpdateAmountSupplementInfoUpdateSupplementEvent(nutriInfo: nutriInfo!));
                          },
                          onRemoveItem: () => updateSupplementBloc.add(RemoveSupplementInfoUpdateSupplementEvent(nutriInfo: nutriInfo!)),
                        );
                      },
                    ),
                    const SizedBox(height: Dimens.height32),
                    if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) GeneralButton(
                      onTap: () {
                        if (state.supplementObj!.name.isNotEmptyOrNull()) {
                          updateSupplementBloc.add(SavingUpdateSupplement(onFinish: () => Navigator.pop(context)));
                        }
                      },
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