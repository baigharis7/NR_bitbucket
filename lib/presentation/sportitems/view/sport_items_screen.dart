import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportupdate/view/sport_update_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/screen_top_bar.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
import '../../../infrastructure/utils/constants.dart';

class SportItemsScreen extends StatefulWidget {
  static const routeName = '/sport_items_screen';

  const SportItemsScreen({super.key});

  @override
  State<SportItemsScreen> createState() => _SportItemsScreenState();
}

class _SportItemsScreenState extends State<SportItemsScreen> with MidnightToastMixin {
  late SportItemsBloc bloc;

  @override
  void initState() {
    super.initState();
    subscribeMidnight();
    bloc = BlocProvider.of<SportItemsBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is DateTime) {
        bloc.add(UpdateDatetimeSportItemsEvents(dateTime: args));
      } else {
        bloc.add(SportItemsInitialization());
      }
    });
  }

  @override
  void dispose() {
    unsubscribeMidnight();
    super.dispose();
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
      value: bloc,
      child: BlocConsumer<SportItemsBloc, SportItemsState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(
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

              Scaffold(
                backgroundColor: Colors.transparent,
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.padding10),
                    child: Column(
                      children: [
                        ScreenTopBar(
                          selectedDate: state.dateTime ?? DateTime.now(),
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: Dimens.height12),
                        HeaderAddItemCardSection(
                          title: '${AppLocalizations.of(context)!.physical_activity} ${AppLocalizations.of(context)!.summary}',
                          image: 'assets/images/sport.png',
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  '${NutritionUtils.calculateKcal(foodEvents: state.sportEvents.orEmpty())} Kcal',
                                  style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize28),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                (state.sportEvents?.isEmpty ?? true)
                                    ? Container(
                                  margin: const EdgeInsets.all(Dimens.marginSmall),
                                  padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge, horizontal: Dimens.padding30),
                                  decoration: BoxDecoration(color: AppColors.floralWhite, borderRadius: BorderRadius.circular(Dimens.border18)),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Text(AppLocalizations.of(context)!.information, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),),
                                      ]),
                                      const SizedBox(height: Dimens.heightXSmall),
                                      Text(
                                        AppLocalizations.of(context)!.physical_summary_exp,
                                        style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, color: AppColors.yellowishGreen),
                                      ),
                                    ],
                                  ),
                                )
                                    : ListView.builder(
                                  shrinkWrap: true,
                                      primary: false,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.sportEvents?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final activity = state.sportEvents![index];
                                        final itemName = activity.sportName ?? NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: activity.info, context: context);

                                        // Check if this is a synced activity
                                        final isSyncedActivity = activity.source != null && activity.source != 'manual';

                                        // Build subtitle with extra info for synced activities
                                        String subtitle = '${AppLocalizations.of(context)!.energy}: -${activity.eventKcals} kcal. - ${(activity.info?.length ?? 0) > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : "${AppLocalizations.of(context)!.duration}: ${activity.info![0].minutes} min."}';

                                        // Add distance and heart rate on a new line for synced activities
                                        if (isSyncedActivity && activity.info != null && activity.info!.isNotEmpty) {
                                          final info = activity.info![0];
                                          final secondLine = <String>[];
                                          if (info.distance != null && info.distance! > 0) {
                                            final distanceStr = info.distance! >= 1000
                                                ? '${(info.distance! / 1000).toStringAsFixed(1)} km'
                                                : '${info.distance!.round()} m';
                                            secondLine.add('${AppLocalizations.of(context)!.distance_label}: $distanceStr');
                                          }
                                          if (info.avgHeartRate != null) {
                                            secondLine.add('${AppLocalizations.of(context)!.heart_rate_label}: ${info.avgHeartRate} bpm');
                                          }
                                          if (secondLine.isNotEmpty) {
                                            subtitle += '\n${secondLine.join(' - ')}';
                                          }
                                        }

                                        return ItemInfoCard(
                                          title: itemName,
                                          subtitle: subtitle,
                                          leadingIcon: isSyncedActivity ? Icons.monitor_heart : null,
                                          leadingIconColor: isSyncedActivity ? AppColors.yellowishGreen : null,
                                          leadingIconSize: isSyncedActivity ? 22 : null,
                                          trailingSrc: 'assets/images/delete_icon.png',
                                          beforeTrailingSrc: isSyncedActivity ? null : 'assets/icon/edit_icon.png',
                                          beforeTrailingTap: isSyncedActivity ? null : () => Navigator.pushNamed(context, SportUpdateScreen.routeName, arguments: activity).then((value) => bloc.add(UpdateDatetimeSportItemsEvents(dateTime: state.dateTime ?? DateTime.now()))),
                                          trailingTap: () => _showRemoveDialog(
                                            description: AppLocalizations.of(context)!.remove_item(itemName),
                                            onCancel: () => Navigator.pop(context),
                                            onConfirm: () => bloc.add(DeleteSportItemSportItemsEvents(sportEventComplete: activity)),
                                          ),
                                        );
                                      },
                                    ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge, bottom: Dimens.marginSmall),
                          child: GeneralButton(
                            title: AppLocalizations.of(context)!.add,
                            onTap: () => Navigator.popAndPushNamed(context, AddSportEventScreen.routeName),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onDelete;

  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.floralWhite,
        borderRadius: BorderRadius.all(Radius.circular(Dimens.border18)),
        boxShadow: [
          BoxShadow(
              color: AppColors.black25Percent,
              offset: Offset(2, 3),
              blurRadius: 3,),
        ],
      ),
      padding: const EdgeInsets.all(Dimens.padding20),
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
      child: Row(
        children: [
          Image.asset(
            'assets/icon/un_favorite_outlined.png',
            width: Dimens.width25,
            height: Dimens.height25,
          ),
          const SizedBox(width: Dimens.width12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.merriWeather.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: Dimens.fontSizeLarge,
                      color: Colors.black),
                ),
                const SizedBox(height: Dimens.height5),
                Text(
                  subtitle,
                  style: AppTextStyles.radioCanadaBig.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.fontSizeXSmall,
                      color: AppColors.battleshipGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimens.width12),
          const Icon(Icons.history,
              size: Dimens.width25),
          const SizedBox(width: Dimens.width12),
          InkWell(
            onTap: () => onDelete.call(),
            child: Image.asset('assets/images/delete_icon.png',
                width: Dimens.width25, height: Dimens.height25),
          ),
        ],
      ),
    );
  }
}
