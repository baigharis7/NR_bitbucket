import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportupdate/view/sport_update_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/date_picker_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';

class SportItemsScreen extends StatelessWidget {
  static const routeName = '/sport_items_screen';

  const SportItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = BlocProvider.of<SportItemsBloc>(context);
    bloc.add(SportItemsInitialization());

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments as DateTime;
      if (args != null) {
        if (args is DateTime) {
          bloc.add(UpdateDatetimeSportItemsEvents(dateTime: args));
        }
      }
    });

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
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.padding10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // const SizedBox(height: Dimens.height12),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: DatePickerBar(selectedDateTime: state.dateTime ?? DateTime.now(), onChangeDate: (dateTime) {
                              bloc.add(UpdateDatetimeSportItemsEvents(dateTime: dateTime));
                            },),
                          ),
                          const SizedBox(height: Dimens.height12),
                          HeaderAddItemCardSection(
                            title: AppLocalizations.of(context)!.physical_activity,
                            image: 'assets/images/sport.png',
                            onBackTap: () => Navigator.pop(context),
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
                          // const SizedBox(height: Dimens.height12),
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
                                  final itemName = NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: activity.info, context: context);
                                  return ItemInfoCard(
                                    title: activity.sportName ?? itemName,
                                    subtitle: '${activity.info![0].minutes} min. -${activity.eventKcals} kcal.',
                                    trailingSrc: 'assets/images/delete_icon.png',
                                    beforeTrailingSrc: 'assets/icon/edit_icon.png',
                                    beforeTrailingTap: () => Navigator.pushNamed(context, SportUpdateScreen.routeName, arguments: activity).then((value) => bloc.add(UpdateDatetimeSportItemsEvents(dateTime: state.dateTime ?? DateTime.now()))),
                                    trailingTap: () => _showRemoveDialog(
                                      description: AppLocalizations.of(context)!.remove_item(itemName),
                                      onCancel: () => Navigator.pop(context),
                                      onConfirm: () => bloc.add(DeleteSportItemSportItemsEvents(sportEventComplete: activity)),
                                    ),
                                  );
                                },
                              ),
                          // Add Activity Button
                          ListTile(
                            onTap: () => Navigator.popAndPushNamed(context, AddSportEventScreen.routeName),
                            leading: Image.asset('assets/images/add_items.png', height: Dimens.height37, width: Dimens.width37),
                            title: Text(
                              AppLocalizations.of(context)!.add_physical_activity,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
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
          Image.asset('assets/icon/routine_icon.png',
              width: Dimens.width25, height: Dimens.height25),
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
