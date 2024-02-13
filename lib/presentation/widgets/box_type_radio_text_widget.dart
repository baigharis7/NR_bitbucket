import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../infrastructure/utils/dimens.dart';

class BoxTypeRadioTextWidget extends StatefulWidget {
  final Function onPressed;
  final bool isSelected;
  final String title;
  final bool showHourDays;
  const BoxTypeRadioTextWidget({super.key, required this.onPressed, required this.isSelected, required this.title, this.showHourDays = false});

  @override
  State<BoxTypeRadioTextWidget> createState() => _BoxTypeRadioTextWidgetState();
}

class _BoxTypeRadioTextWidgetState extends State<BoxTypeRadioTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall, horizontal: Dimens.paddingSmall),
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginNormal),
          child: Column(
            children: [
              InkWell(
                onTap: () => widget.onPressed.call(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeMedium,
                        ),
                      ),
                    ),
                    Container(
                      height: 21,
                      width: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: Dimens.borderSmall,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showHourDays && widget.isSelected) const SizedBox(height: Dimens.heightXSmall,),
              if (widget.showHourDays && widget.isSelected) Row(children: [
                Expanded(child: Text(AppLocalizations.of(context)!.hour)),
                Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall), color: AppColors.cardGreen_200, child: const Text('00:00'))),
                const Spacer(),
                Expanded(child: Text(AppLocalizations.of(context)!.day)),
                Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.marginSmall), color: AppColors.cardGreen_200, child: const Icon(Icons.calendar_today_outlined, size: 22,))),
              ],),
            ],
          ),
        ),
    );
  }
}