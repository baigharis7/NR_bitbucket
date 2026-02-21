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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              !leadingSrc.isNull() && !leadingTap.isNull() ? InkWell(onTap: () => leadingTap?.call(), child: Image.asset(leadingSrc!, width: leadingIconSize ?? 17, height: leadingIconSize ?? 17)) : SizedBox(width: leadingIconSize ?? 17, height: leadingIconSize ?? 17),
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
                  style: const TextStyle(color: AppColors.battleshipGrey, fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeXSmall),
                ) : const SizedBox(),
              ],),),
              const SizedBox(width: Dimens.width12),
              if(beforeTrailingSrc.isNotNull() && !beforeTrailingTap.isNull()) InkWell(onTap: beforeTrailingTap, child: Image.asset(beforeTrailingSrc!, height: 21, width: 21, color: AppColors.yellowishGreen,)),
              const SizedBox(width: Dimens.width12),
              !trailingSrc.isNull() && !trailingTap.isNull() ? InkWell(onTap: () => trailingTap?.call(), child: Image.asset(trailingSrc!, height: 21, width: 21)) : const SizedBox(),
            ],
          ),
          // ListTile(
          //   onTap: onItemTap,
          //   // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   titleAlignment: ListTileTitleAlignment.center,
          //   horizontalTitleGap: 0,
          //   leading: !leadingSrc.isNull() && !leadingTap.isNull() ? InkWell(onTap: () => leadingTap?.call(), child: Image.asset(leadingSrc!, width: leadingIconSize ?? 17, height: leadingIconSize ?? 17)) : const SizedBox(),
          //   title: Text(
          //     title,
          //     style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,
          //   ),
          //   subtitle: !subtitle.isNull() ? Text(
          //     subtitle!,
          //     style: const TextStyle(color: AppColors.battleshipGrey, fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeXSmall),
          //   ) : const SizedBox(),
          //   trailing: !trailingSrc.isNull() && !trailingTap.isNull() ? InkWell(onTap: () => trailingTap?.call(), child: Image.asset(trailingSrc!, height: 21, width: 21)) : const SizedBox(),
          // ),
        ],
      ),
    );
  }

}