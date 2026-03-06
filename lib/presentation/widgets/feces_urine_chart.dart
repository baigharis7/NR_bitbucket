import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class FecesUrineChart extends StatelessWidget {
  final List<Map<String, dynamic>> valuesList;
  final List<String?> imagePaths;
  const FecesUrineChart({super.key, required this.valuesList, required this.imagePaths});


  @override
  Widget build(BuildContext context) {
    if (imagePaths.isNotEmpty) imagePaths.orEmpty().removeWhere((element) => element.isEmptyOrNull());
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.yellowishGreen59,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.evolution_14_days,
            style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17,),
          ),
          // const SizedBox(height: Dimens.height5),
          // const Text(
          //   '7 / 14 days registered.',
          //   style: TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize13, color: Colors.white),
          // ),
          const SizedBox(height: Dimens.height12),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(valuesList.length, (index) {
                return Container(
                  width: 10,
                  height: (valuesList[index]['count'] / 100) * 70, // max 70px
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(Dimens.border8)),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.white,),
          const SizedBox(height: Dimens.height12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(imagePaths.length, (index) {
              return Container(
                padding: const EdgeInsets.all(Dimens.padding4),
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
                child: imagePaths[index].isEmptyOrNull() ? const SizedBox(height: 20, width: 20,) : Image.asset(imagePaths[index]!, width: 20, height: 20,),
              );
            }),
          ),
        ],
      ),
    );
  }

}