import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../infrastructure/utils/app_color.dart';

class SwitchDashboardWidget extends StatefulWidget {
  final String title;
  final bool currentState;
  final Function(bool) onStateChange;
  final Color? backgroundColor;
  final Color? color;

  const SwitchDashboardWidget({
    Key? key,
    required this.title,
    required this.currentState,
    required this.onStateChange,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SwitchDashboardWidgetState();
}

class _SwitchDashboardWidgetState extends State<SwitchDashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.backgroundColor ?? AppColors.darkJungleGreen,
      margin: const EdgeInsets.symmetric(
          horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.border15)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title,
                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize13, color: widget.color),),
            Switch.adaptive(
              inactiveTrackColor: Colors.white,
              thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (widget.currentState == true) {
                  return widget.color ?? AppColors.mountainMeadow;
                } else {
                  return Colors.white;
                }
              }),
              applyCupertinoTheme: true,
              value: widget.currentState,
              activeColor: Colors.white,
              onChanged: (bool value) {
                widget.onStateChange.call(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
