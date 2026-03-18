import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../infrastructure/utils/app_color.dart';

class TextRadioButtonExpansible extends StatelessWidget {
  final String title;
  final String explanation;
  final bool isSelected;
  final Function onPressed;

  const TextRadioButtonExpansible({
    Key? key,
    required this.title,
    required this.explanation,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed.call(),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: Dimens.height12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen),
                    ),
                  ),
                  Container(
                    height: 21,
                    width: 21,
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.cloudyGrey,
                        width: Dimens.borderSmall,
                      ),
                    ),
                    child: Container(
                      margin: isSelected ? const EdgeInsets.symmetric(horizontal: 2, vertical: 2) : null,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.carbonGrey : AppColors.carbonGrey27,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.heightXXSmall),
              if (explanation != '') Text(
                explanation,
                maxLines: 3,
                overflow: TextOverflow.clip,
                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize11, color: AppColors.yellowishGreen),
              ),
              if (explanation != '') const SizedBox(height: Dimens.heightXXSmall),
            ],),
          ),
          const Divider(color: AppColors.cloudyGrey, height: 1, thickness: 1,),
        ],
      ),
    );
  }

}