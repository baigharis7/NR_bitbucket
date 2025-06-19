import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ItemInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? leadingSrc;
  final String? trailingSrc;
  final VoidCallback? leadingTap;
  final VoidCallback? trailingTap;
  final Color? color;
  const ItemInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingSrc,
    this.trailingSrc,
    this.leadingTap,
    this.trailingTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginLarge),
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
      child: ListTile(
        // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        titleAlignment: ListTileTitleAlignment.center,
        horizontalTitleGap: 0,
        leading: !leadingSrc.isNull() && !leadingTap.isNull() ? InkWell(onTap: () => leadingTap?.call(), child: Image.asset(leadingSrc!, width: 17, height: 17)) : const SizedBox(),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge,), maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: !subtitle.isNull() ? Text(
          subtitle!,
          style: const TextStyle(color: AppColors.battleshipGrey, fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeXSmall),
        ) : const SizedBox(),
        trailing: !trailingSrc.isNull() && !trailingTap.isNull() ? InkWell(onTap: () => trailingTap?.call(), child: Image.asset(trailingSrc!, height: 21, width: 21)) : const SizedBox(),
      ),
    );
  }

}