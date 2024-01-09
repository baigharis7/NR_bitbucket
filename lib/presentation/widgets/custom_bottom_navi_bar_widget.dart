import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../infrastructure/helpers/toast_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../journal/view/journal_screen.dart';
import '../recipes/common/view/recipe_tabs_holder.dart';
import '../recommendations/common/view/recommendations_tabs_holder.dart';
import '../recommendations/recipes/view/recipes_tab.dart';

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
    return BottomNavigationBar(
      selectedItemColor: AppColors.mountainMeadow,
      currentIndex: widget.activePosition,
      // currentIndex: currentPosition,
      showUnselectedLabels: true,
      unselectedItemColor: Colors.black87,
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: Dimens.fontSizeSmall,
      selectedFontSize: Dimens.fontSizeSmall,
      items: [
        BottomNavigationBarItem(icon: SvgPicture.asset('assets/images/start.svg',), label: 'Start', activeIcon: SvgPicture.asset(
          'assets/images/start.svg',
          colorFilter: const ColorFilter.mode(AppColors.mountainMeadow, BlendMode.srcIn),
        ),),BottomNavigationBarItem(icon: SvgPicture.asset('assets/images/diary.svg',), label: 'Diary', activeIcon: SvgPicture.asset(
          'assets/images/diary.svg',
          colorFilter: const ColorFilter.mode(AppColors.mountainMeadow, BlendMode.srcIn),
        ),),BottomNavigationBarItem(icon: SvgPicture.asset('assets/images/tips.svg',), label: 'Tips', activeIcon: SvgPicture.asset(
          'assets/images/tips.svg',
          colorFilter: const ColorFilter.mode(AppColors.mountainMeadow, BlendMode.srcIn),
        ),),BottomNavigationBarItem(icon: SvgPicture.asset('assets/images/recipes.svg',), label: 'Recipes', activeIcon: SvgPicture.asset(
          'assets/images/recipes.svg',
          colorFilter: const ColorFilter.mode(AppColors.mountainMeadow, BlendMode.srcIn),
        ),),
      ],
      onTap: (value) {
        // currentPosition = value;
        // ToastHelper().showToast(text: value.toString());
        // setState(() {});
        switch(value) {
          case 0: {
            if (ModalRoute.of(context)!.settings.name != DashboardScreen.routeName) {
              Navigator.popAndPushNamed(context, DashboardScreen.routeName).then((value) {});
            }
          }
          break;

          case 1: {
            if (ModalRoute.of(context)!.settings.name != JournalScreen.routeName) {
              Navigator.popAndPushNamed(context, JournalScreen.routeName).then((value) {});
            }
          }
          break;

          case 2: {
            if (ModalRoute.of(context)!.settings.name != RecommendationsTabHolder.routeName) {
              Navigator.popAndPushNamed(context, RecommendationsTabHolder.routeName).then((value) {});
            }
          }
          break;

          case 3: {
            if (ModalRoute.of(context)!.settings.name != RecipesTabsHolder.routeName) {
              Navigator.popAndPushNamed(context, RecipesTabsHolder.routeName).then((value) {});
            }
          }
          break;
        }
      },
    );
  }
}