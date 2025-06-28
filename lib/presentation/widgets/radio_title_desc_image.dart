import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import '../../domain/models/profile/feces.dart';
import '../../infrastructure/utils/dimens.dart';

class RadioTitleDescImage extends StatelessWidget {
  final bool isSelected;
  final Feces fece;
  final Function(int?) onSelect;

  const RadioTitleDescImage({super.key, required this.isSelected, required this.fece, required this.onSelect,});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
          decoration: BoxDecoration(
            color: isSelected == true ? AppColors.yellowishGreen : AppColors.white65Percent,
            border: Border.all(width: 1, color: AppColors.white50Percent,),
              borderRadius: const BorderRadius.all(Radius.circular(Dimens.border8)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.silverSand40Percent,
                blurRadius: 4,
                // spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => onSelect.call(fece.id),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: Dimens.marginNormal),
                  child: Container(
                    height: Dimens.heightXSmall - 2,
                    width: Dimens.heightXSmall - 2,
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
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(fece.title ?? '', style: TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeNormal, color: isSelected ? Colors.white : Colors.black)),
                      if (fece.description?.isNotEmpty ?? false) const SizedBox(height: Dimens.height5),
                    if (fece.description?.isNotEmpty ?? false) Text(fece.description ?? '',  style: TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize13, color: isSelected ? Colors.white : Colors.black)),
                  ],),
                ),
                if (fece.image?.isNotEmpty ?? false) Container(
                  padding: const EdgeInsets.all(Dimens.paddingNormal),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimens.border100),
                    ),
                    child: Image.asset(fece.image!, width: 34, height: 34,),
                ),
              ],
            ),
          ),
        ),
        if (fece.image?.isNotEmpty ?? false) Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
          padding: const EdgeInsets.all(Dimens.paddingNormal),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimens.border100),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black25Percent,
                blurRadius: 4,
                // spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(fece.image!, width: 70, height: 70,),
        ),
      ],
    );
  }
}
