import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class DashTitleWidget extends StatelessWidget {
  final String? title;
  final Function? onInfoClick;
  const DashTitleWidget({super.key, this.title, this.onInfoClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title.isNotNull()) Container(
          height: 39,
          decoration: const BoxDecoration(color: AppColors.darkJungleGreen, borderRadius: BorderRadius.horizontal(right: Radius.circular(50))),
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge,),
          alignment: Alignment.center,
          child: Text(
            title ?? '', style: const TextStyle(fontSize: Dimens.fontSize20, color: Colors.white, fontWeight: FontWeight.w300),
          ),
        ),
        const Spacer(),
        if (!onInfoClick.isNull()) InkWell(onTap: () => onInfoClick?.call(), child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), width: 18, height: 18, child: Image.asset('assets/images/info.png',))),
      ],
    );
  }
}
