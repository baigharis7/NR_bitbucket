import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RemoveItemWidget extends StatelessWidget {
  final String description;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RemoveItemWidget({
    Key? key,
    required this.description,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(16),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/delete_icon.png', color: Colors.white, height: Dimens.height42, width: Dimens.width32,),
          const SizedBox(height: Dimens.height25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimens.padding20),
            decoration: BoxDecoration(
              color: AppColors.white85Percent,
              borderRadius: BorderRadius.circular(Dimens.border20),
            ),
            child: Column(children: [
              Text(
                AppLocalizations.of(context)!.remove_item_title,
                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen),
              ),
              const SizedBox(height: Dimens.heightXSmall),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen),
              ),
              const SizedBox(height: Dimens.heightXSmall),
            ],),
          ),
          const SizedBox(height: Dimens.heightXSmall),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.border50,),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimens.padding4),
                  ),
                  child: Text(AppLocalizations.of(context)!.no, style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize13,)),
                ),
              ),
              const SizedBox(width: Dimens.width12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepAquamarine,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.border50),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimens.padding4),
                  ),
                  child: Text(AppLocalizations.of(context)!.yes, style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize13,)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
