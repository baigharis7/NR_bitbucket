import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class DashTitleWidget extends StatelessWidget {
  final String? title;
  final Function? onInfoClick;
  final TextStyle? style;
  const DashTitleWidget({super.key, this.title, this.onInfoClick, this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
      ),
      child: Row(
        children: [
          if (title.isNotNull()) Text(
            title ?? '', style: style ?? AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize19),
          ),
          const Spacer(),
          if (!onInfoClick.isNull()) InkWell(onTap: () => onInfoClick?.call(), child: SizedBox(width: 18, height: 18, child: Image.asset('assets/images/info.png',))),
        ],
      ),
    );
  }
}
