import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/bloc/supplements_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/supplement_item_widget.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/header_add_item_card_section.dart';

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

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingLarge,
                ),
                child: Column(children: [
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
                      focus.unfocus();
                      final supplement = NutritionUtils.findSupplementByName(state.supplementsInfo?.data ?? [], supplementName, context);
                      supplementsBloc.add(AddSupplementInfoSupplementsAction(nutriInfo: NutriInfo(id: supplement.id, unit: supplement.unit, amount: 0)));
                    },
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
                          supplementsBloc.add(UpdateAmountSupplementsAction(nutriInfo: nutriInfo!));
                        },
                        onRemoveItem: () => supplementsBloc.add(RemoveSupplementInfoSupplementsAction(nutriInfo: nutriInfo!)),
                      );
                    },
                  ),
                  const SizedBox(height: Dimens.height32),
                  if (state.supplementObj?.info?.orEmpty().isNotEmpty == true) GeneralButton(
                    onTap: () {
                      supplementsBloc.add(SavingEventSupplementsAction());
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
