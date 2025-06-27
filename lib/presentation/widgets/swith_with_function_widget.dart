import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: TextStyle(color: widget.color ?? Colors.white,fontWeight: FontWeight.w400, fontSize: Dimens.fontSize13)),
            Switch.adaptive(
              inactiveTrackColor: Colors.white,
              activeTrackColor: widget.color ?? AppColors.mountainMeadow,
              applyCupertinoTheme: true,
              value: widget.currentState,
              activeColor: widget.color ?? AppColors.mountainMeadow,
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
