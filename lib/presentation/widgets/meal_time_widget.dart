import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class MealTimeWidget extends StatelessWidget {
  final String name;
  final String? svg;
  final String? backgroundImage;
  final String? desc;
  final Color? iconColor;
  final Color? backgroundColor;
  final Function onClick;
  const MealTimeWidget({super.key, required this.name, this.svg, required this.onClick, this.backgroundImage, this.desc, this.iconColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick.call(),
      child: Card(clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border20), side: const BorderSide(color: Colors.white, width: 1,)),
        elevation: 10,
        color: backgroundColor ?? AppColors.floralWhite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
          decoration: BoxDecoration(
            color: backgroundImage.isNull() ? null : Colors.white,
            image: backgroundImage != null ? DecorationImage(
              image: AssetImage(backgroundImage!), // Your image
              fit: BoxFit.cover,
              opacity: 0.35,
            ) : null,
          ),
          child: Row(children: [
            if (svg != null) SizedBox(height: 49, width: 49, child: Image.asset(svg!,)),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TextStyle(fontSize: Dimens.fontSizeXLarge, color: iconColor),),
                  const SizedBox(height: Dimens.heightXXSmall),
                  if (desc.isNotNull()) Text(desc!, style: TextStyle(fontSize: Dimens.fontSizeSmall, color: iconColor ?? AppColors.battleshipGrey),),
                ],),
              ),
            ),
            InkWell(onTap: () => onClick.call(), child: Icon(Icons.add_circle, size: 26, color: iconColor)),
          ],),
        ),
      ),
    );
  }

}