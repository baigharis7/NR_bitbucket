import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/horizontal_bar_widget.dart';

import '../../infrastructure/lists/SupplementInfo.dart';
import '../../infrastructure/utils/dimens.dart';

class NutrientDetailWidget extends StatelessWidget {
  final SupplementInfo? todayCreatine;
  final Function(SupplementInfo?)? onMinusClick;
  final Function(SupplementInfo?)? onPlusClick;

  const NutrientDetailWidget({
    super.key,
    required this.todayCreatine,
    this.onMinusClick,
    this.onPlusClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
            alignment: Alignment.centerLeft,
            child: Text(
              todayCreatine.translate(context),
              style: const TextStyle(fontSize: Dimens.fontSizeMedium),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              HorizontalBarWidget(fillBarValue: (todayCreatine?.uploadSupplementEvent?.value ?? 0) / (todayCreatine?.rda ?? 0.0)),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                child: Row(
                  children: [
                    if (onMinusClick != null)
                      InkWell(
                        onTap: () => onMinusClick?.call(todayCreatine),
                        child: const Icon(Icons.remove_circle_outline),
                      ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.center,
                        '${todayCreatine?.uploadSupplementEvent?.value ?? 0} g',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: Dimens.fontSizeMedium,
                        ),
                      ),
                    ),
                    if (onPlusClick != null)
                      InkWell(
                        onTap: () => onPlusClick?.call(todayCreatine),
                        child: const Icon(Icons.add_circle_outline),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimens.marginSmall,
              vertical: Dimens.marginXSmall,
            ),
            child: Text(
              '${todayCreatine?.rda ?? 0} g',
              style: const TextStyle(
                fontSize: Dimens.fontSizeNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
