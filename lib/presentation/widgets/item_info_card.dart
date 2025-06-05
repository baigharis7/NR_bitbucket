import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ItemInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;
  const ItemInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    required this.onFavorite,});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
      decoration: BoxDecoration(
        color: AppColors.floralWhite, // light greenish
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
        leading: /*Image.asset('assets/images/favorite_icon.png', width: 17, height: 17)*/ const SizedBox(),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge,), maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.battleshipGrey, fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeXSmall),
        ),
        trailing: Image.asset('assets/images/delete_icon.png', height: 21, width: 17),
      ),
    );
  }

}