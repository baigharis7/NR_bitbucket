import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class MealTimeWidget extends StatelessWidget {
  final String name;
  final String svg;
  final String desc;
  final Color? iconColor;
  final Color? backgroundColor;
  const MealTimeWidget({super.key, required this.name, required this.svg, required this.desc, this.iconColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border20), side: const BorderSide(color: Colors.white, width: 1,)),
      elevation: 10,
      color: backgroundColor ?? AppColors.floralWhite,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginLarge),
        child: Row(children: [
          SizedBox(width: Dimens.widthSmall, height: Dimens.heightSmall, child: SvgPicture.asset(svg,)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: TextStyle(fontSize: Dimens.fontSizeXLarge, color: iconColor),),
                const SizedBox(height: Dimens.heightXXSmall),
                Text(desc, style: TextStyle(fontSize: Dimens.fontSizeSmall, color: iconColor ?? AppColors.battleshipGrey),),
              ],),
            ),
          ),
          Icon(Icons.add_circle, size: 35, color: iconColor),
        ],),
      ),
    );
  }

}