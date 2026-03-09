import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../infrastructure/helpers/app_text_styles.dart';

class MealTimeWidget extends StatelessWidget {
  final String name;
  final String? svg;
  final String? backgroundImage;
  final String? desc;
  final Color? iconColor;
  final Color? backgroundColor;
  final Function onClick;
  final Function? onItemClick;
  final bool compact;
  const MealTimeWidget({super.key, required this.name, this.svg, required this.onClick, this.backgroundImage, this.desc, this.iconColor, this.backgroundColor, this.onItemClick, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return InkWell(
      onTap: () => onItemClick?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.floralWhite,
          borderRadius: BorderRadius.circular(Dimens.border20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            if (svg != null) SizedBox(height: 38, width: 38, child: Image.asset(svg!)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeMedium, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (desc.isNotNull()) Text(
                    desc!,
                    style: TextStyle(fontSize: Dimens.fontSizeSmall, color: iconColor ?? AppColors.battleshipGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => onClick.call(),
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.add_circle, size: 26, color: iconColor ?? AppColors.yellowishGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return InkWell(
      onTap: () => onItemClick?.call(),
      child: Card(clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border20), side: const BorderSide(color: Colors.white, width: 1,)),
        elevation: 10,
        color: backgroundColor ?? AppColors.floralWhite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
          decoration: BoxDecoration(
            color: backgroundImage.isNull() ? null : Colors.white,
            image: backgroundImage != null ? DecorationImage(
              image: AssetImage(backgroundImage!),
              fit: BoxFit.cover,
              opacity: 0.35,
            ) : null,
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (svg != null) SizedBox(height: 49, width: 49, child: Image.asset(svg!,)),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black),),
                  const SizedBox(height: Dimens.heightXXSmall),
                  if (desc.isNotNull()) Text(desc!, style: TextStyle(fontSize: Dimens.fontSize13, color: iconColor ?? AppColors.battleshipGrey),),
                ],),
              ),
            ),
            InkWell(onTap: () => onClick.call(), child: Padding(padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 4), child: Icon(Icons.add_circle, size: 32, color: iconColor ?? AppColors.yellowishGreen))),
          ],),
        ),
      ),
    );
  }
}
