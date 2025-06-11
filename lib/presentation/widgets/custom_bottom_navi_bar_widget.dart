import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../journal/view/journal_screen.dart';
import '../recipes/common/view/recipe_tabs_holder.dart';
import '../recommendations/common/view/recommendations_tabs_holder.dart';

class CustomBottomNaviBarWidget extends StatefulWidget {
  final int activePosition;
  const CustomBottomNaviBarWidget({super.key, required this.activePosition});

  @override
  State<CustomBottomNaviBarWidget> createState() => _CustomBottomNaviBarWidgetState();
}

class _CustomBottomNaviBarWidgetState extends State<CustomBottomNaviBarWidget> {
  // int currentPosition = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(
          color: AppColors.black25Percent,
          offset: Offset(-3, -3),
          blurRadius: 5
        )]
      ),
      child: BottomNavigationBar(
        selectedItemColor: AppColors.darkJungleGreen,
        currentIndex: widget.activePosition,
        // currentIndex: currentPosition,
        showUnselectedLabels: true,
        unselectedItemColor: AppColors.cloudyGrey,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: Dimens.fontSizeSmall,
        selectedFontSize: Dimens.fontSizeSmall,
        iconSize: 20,
        items: [
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: SvgPicture.asset('assets/images/start.svg', colorFilter: const ColorFilter.mode(AppColors.cloudyGrey, BlendMode.srcIn),)), label: AppLocalizations.of(context)!.start, activeIcon: SizedBox(height: 35,
            child: SvgPicture.asset(
              'assets/images/start.svg',
              colorFilter: const ColorFilter.mode(AppColors.darkJungleGreen, BlendMode.srcIn),
            ),
          ), tooltip: AppLocalizations.of(context)!.start,),
          // BottomNavigationBarItem(icon: SizedBox(height: 35, child: SvgPicture.asset('assets/images/diary.svg', colorFilter: const ColorFilter.mode(AppColors.cloudyGrey, BlendMode.srcIn),)), label: AppLocalizations.of(context)!.diary, activeIcon: SizedBox(height: 35,
          //   child: SvgPicture.asset(
          //     'assets/images/diary.svg',
          //     colorFilter: const ColorFilter.mode(AppColors.darkJungleGreen, BlendMode.srcIn),
          //   ),
          // ), tooltip: AppLocalizations.of(context)!.diary,),
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: SvgPicture.asset('assets/images/tips.svg', colorFilter: const ColorFilter.mode(AppColors.cloudyGrey, BlendMode.srcIn),)), label: AppLocalizations.of(context)!.tips, activeIcon: SizedBox(height: 35,
            child: SvgPicture.asset(
              'assets/images/tips.svg',
              colorFilter: const ColorFilter.mode(AppColors.darkJungleGreen, BlendMode.srcIn),
            ),
          ), tooltip: AppLocalizations.of(context)!.tips,),
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: SvgPicture.asset('assets/images/recipes.svg', colorFilter: const ColorFilter.mode(AppColors.cloudyGrey, BlendMode.srcIn),)), label: AppLocalizations.of(context)!.recipes, activeIcon: SizedBox(height: 35,
            child: SvgPicture.asset(
              'assets/images/recipes.svg',
              colorFilter: const ColorFilter.mode(AppColors.darkJungleGreen, BlendMode.srcIn),
            ),
          ), tooltip: AppLocalizations.of(context)!.recipes,),
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: SvgPicture.asset('assets/images/profile.svg', colorFilter: const ColorFilter.mode(AppColors.cloudyGrey, BlendMode.srcIn),)), label: AppLocalizations.of(context)!.profile, activeIcon: SizedBox(height: 35,
            child: SvgPicture.asset(
              'assets/images/profile.svg',
              colorFilter: const ColorFilter.mode(AppColors.darkJungleGreen, BlendMode.srcIn),
            ),
          ), tooltip: AppLocalizations.of(context)!.profile,),
        ],
        onTap: (value) {
          // currentPosition = value;
          // ToastHelper().showToast(text: value.toString());
          // setState(() {});
          switch(value) {
            case 0: {
              if (ModalRoute.of(context)!.settings.name != DashboardScreen.routeName) {
                // Navigator.popAndPushNamed(context, DashboardScreen.routeName).then((value) {});
                Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName, (route) => false,).then((value) => {});
              }
            }
            break;

            // case 1: {
            //   if (ModalRoute.of(context)!.settings.name != JournalScreen.routeName) {
            //     // Navigator.popAndPushNamed(context, JournalScreen.routeName).then((value) {});
            //     Navigator.pushNamedAndRemoveUntil(context, JournalScreen.routeName, (route) => false,).then((value) => {});
            //   }
            // }
            // break;

            case 1: {
              if (ModalRoute.of(context)!.settings.name != RecommendationsTabHolder.routeName) {
                // Navigator.popAndPushNamed(context, RecommendationsTabHolder.routeName).then((value) {});
                Navigator.pushNamedAndRemoveUntil(context, RecommendationsTabHolder.routeName, (route) => false,).then((value) => {});
              }
            }
            break;

            case 2: {
              if (ModalRoute.of(context)!.settings.name != RecipesTabsHolder.routeName) {
                // Navigator.popAndPushNamed(context, RecipesTabsHolder.routeName).then((value) {});
                Navigator.pushNamedAndRemoveUntil(context, RecipesTabsHolder.routeName, (route) => false,).then((value) => {});
              }
            }
            break;

            case 3: {
              if (ModalRoute.of(context)!.settings.name != ProfileScreen.routeName) {
                // Navigator.popAndPushNamed(context, RecipesTabsHolder.routeName).then((value) {});
                Navigator.pushNamedAndRemoveUntil(context, ProfileScreen.routeName, (route) => false,).then((value) => {});
              }
            }
            break;
          }
        },
      ),
    );
  }
}