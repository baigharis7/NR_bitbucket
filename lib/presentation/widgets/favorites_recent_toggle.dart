import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class FavoritesRecentToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool showFavoritesTab;

  const FavoritesRecentToggle({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.showFavoritesTab = true,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppLocalizations.of(context)!.recent.toUpperCase(),
      if (showFavoritesTab) AppLocalizations.of(context)!.favorites.toUpperCase(),
    ];

    final icons = [
      Icons.schedule,
      if (showFavoritesTab) Icons.star_rounded,
    ];

    return Row(
      children: [
        ...List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          final iconColor = isSelected ? Colors.white : AppColors.yellowishGreen;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                height: 45,
                margin: const EdgeInsets.symmetric(horizontal: Dimens.padding6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.border15),
                  color: isSelected ? AppColors.yellowishGreen59 : AppColors.butter59,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 17,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: iconColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (!showFavoritesTab) const Expanded(child: SizedBox()),
      ],
    );
  }
}
