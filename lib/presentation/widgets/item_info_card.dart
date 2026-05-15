import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ItemInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? leadingSrc;
  final String? trailingSrc;
  final String? beforeTrailingSrc;
  final VoidCallback? leadingTap;
  final VoidCallback? trailingTap;
  final VoidCallback? beforeTrailingTap;
  final Color? color;
  final VoidCallback? onItemTap;
  final double? leadingIconSize;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final IconData? trailingIcon;
  final IconData? beforeTrailingIcon;
  const ItemInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingSrc,
    this.trailingSrc,
    this.beforeTrailingSrc,
    this.leadingTap,
    this.trailingTap,
    this.beforeTrailingTap,
    this.color,
    this.onItemTap,
    this.leadingIconSize,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailingIcon,
    this.beforeTrailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge),
      padding: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginLarge),
      decoration: BoxDecoration(
        color: color ?? AppColors.floralWhite, // light greenish
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (!leadingSrc.isNull() || leadingIcon != null)
              leadingTap != null
                ? InkWell(
                    onTap: () => leadingTap?.call(),
                    child: leadingIcon != null
                      ? Icon(leadingIcon, size: leadingIconSize ?? 17, color: leadingIconColor)
                      : Image.asset(leadingSrc!, width: leadingIconSize ?? 17, height: leadingIconSize ?? 17),
                  )
                : (leadingIcon != null
                    ? Icon(leadingIcon, size: leadingIconSize ?? 17, color: leadingIconColor)
                    : Image.asset(leadingSrc!, width: leadingIconSize ?? 17, height: leadingIconSize ?? 17)),
              const SizedBox(width: Dimens.width12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  title,
                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                  const SizedBox(height: Dimens.heightXXSmall),
                !subtitle.isNull() ? Text(
                  subtitle!,
                  style: const TextStyle(color: AppColors.battleshipGrey, fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeXSmall, height: 1.6),
                ) : const SizedBox(),
              ],),),
              if((!beforeTrailingSrc.isNull() || beforeTrailingIcon != null) && !beforeTrailingTap.isNull()) ...[
                const SizedBox(width: Dimens.marginSmall),
                InkWell(
                  onTap: beforeTrailingTap,
                  child: beforeTrailingIcon != null
                    ? Icon(beforeTrailingIcon, size: 26, color: AppColors.yellowishGreen)
                    : Image.asset(beforeTrailingSrc!, height: 26, width: 26, color: AppColors.yellowishGreen),
                ),
              ],
              if((!trailingSrc.isNull() || trailingIcon != null) && !trailingTap.isNull()) ...[
                const SizedBox(width: Dimens.marginSmall),
                InkWell(
                  onTap: () => trailingTap?.call(),
                  child: trailingIcon != null
                    ? Icon(trailingIcon, size: 26, color: AppColors.yellowishGreen)
                    : Image.asset(trailingSrc!, height: 26, width: 26),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    // Without a body tap handler, the card is presentational (or only the
    // trailing icons are interactive). Otherwise wrap the whole card so
    // testers can tap anywhere — previously only the small "+" icon worked,
    // which made Recent/Favorites items feel non-functional.
    if (onItemTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onItemTap,
      child: card,
    );
  }

}