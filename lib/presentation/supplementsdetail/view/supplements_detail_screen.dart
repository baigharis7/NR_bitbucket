import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/remove_item_widget.dart';

class SupplementsDetailScreen extends StatefulWidget {
  static const routeName = '/supplements_detail_screen';

  const SupplementsDetailScreen({super.key});

  @override
  State<SupplementsDetailScreen> createState() => _SupplementsDetailScreen();
}

class _SupplementsDetailScreen extends State<SupplementsDetailScreen> {
  late SupplementsDetailBloc supplementsDetailBloc;

  @override
  void initState() {
    supplementsDetailBloc = BlocProvider.of<SupplementsDetailBloc>(context);
    supplementsDetailBloc.add(InitializeSupplementsDetailEvent(eventDate: DateTime.now()));

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is int) {
            supplementsDetailBloc.add(InitializeSupplementsDetailEvent(eventDate: DateTimeHelper.dateTimeFromMilliseconds(infoReceived)));
          }
        }
      }
    });

    super.initState();
  }

  // TODO: Remove Item from db
  void _showRemoveDialog({required String description, required VoidCallback onCancel, required VoidCallback onConfirm}) {
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => RemoveItemWidget(
        description: description,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: supplementsDetailBloc,
      child: BlocConsumer<SupplementsDetailBloc, SupplementsDetailState>(
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
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingLarge,
                  ),
                  child: Column(children: [
                    DatePickerBar(
                      selectedDateTime: state.eventDate,
                      onChangeDate: (dateTime) => supplementsDetailBloc.add(UpdateEventsDateSupplementsDetailEvent(dateTime: dateTime)),
                    ),
                    const SizedBox(height: Dimens.height12),
                    HeaderAddItemCardSection(
                      onBackTap: () => Navigator.pop(context),
                      title: '${AppLocalizations.of(context)!.supplements} ${AppLocalizations.of(context)!.summary}',
                      image: 'assets/images/supplement.png',
                    ),
                    if (state.userProfile?.objectives?.any((element) => element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) const SizedBox(height: Dimens.height12),
                    if (state.userProfile?.objectives?.any((element) => element ==  Constants.REDUCE_RISK_OF_INJURY || element == Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) Container(
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
                          trailingSrc: 'assets/images/delete_icon.png',
                          trailingTap: state.supplemntCreatines.orEmpty().isNotEmpty == true ? () => supplementsDetailBloc.add(DeleteSupplementEventAction(supplement: state.supplemntCreatines!.first)) : null,
                          subtitle: '${state.totalAmountCreatine.orZero()} mg',
                          leadingSrc: 'assets/images/goal_objectives.png',
                          leadingTap: () {},
                        ),
                        if (state.userProfile?.objectives?.contains(Constants.RECOVERY_AFTER_SPORT_INJURY) ?? false) ItemInfoCard(
                          title: AppLocalizations.of(context)!.collagen,
                          leadingIconSize: Dimens.height25,
                          trailingSrc: 'assets/images/delete_icon.png',
                          trailingTap: state.supplemntCollagens.orEmpty().isNotEmpty == true ? () => supplementsDetailBloc.add(DeleteSupplementEventAction(supplement: state.supplemntCollagens!.first)) : null,
                          subtitle: '${state.totalAmountCollagen.orZero()} mg',
                          leadingSrc: 'assets/images/goal_objectives.png',
                          leadingTap: () {},
                        ),
                      ],),
                    ),
                    const SizedBox(height: Dimens.height12),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: state.supplementEvents.length,
                      itemBuilder: (context, index) {
                        final supplement = state.supplementEvents[index];
                        final itemName = supplement.name ?? NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], supplement.info.orEmpty()[0].id).translate(context);
                        return ItemInfoCard(
                            title: itemName,
                          trailingSrc: 'assets/images/delete_icon.png',
                          subtitle: supplement.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${supplement.info![0].amount.toString()} ${supplement.info![0].unit}.',
                          trailingTap: () => _showRemoveDialog(
                              description: AppLocalizations.of(context)!.remove_item(itemName),
                              onCancel: () => Navigator.pop(context),
                              onConfirm: () => supplementsDetailBloc.add(DeleteSupplementEventAction(supplement: supplement)),
                          ),
                            beforeTrailingSrc: 'assets/icon/edit_icon.png',
                            beforeTrailingTap: () => Navigator.popAndPushNamed(context, SupplementsScreen.routeName, arguments: supplement),
                        );
                      },
                    ),
                    const SizedBox(height: Dimens.height32),
                    ListTile(
                      onTap: () => Navigator.popAndPushNamed(context, SupplementsScreen.routeName),
                      leading: Image.asset('assets/images/add_items.png', height: Dimens.height37, width: Dimens.width37),
                      title: Text(
                        AppLocalizations.of(context)!.add + ' ' +AppLocalizations.of(context)!.supplements,
                        style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
