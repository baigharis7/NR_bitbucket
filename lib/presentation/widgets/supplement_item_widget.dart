import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class SupplementItemWidget extends StatelessWidget {
  final bool _error = false;
  final VoidCallback onRemoveItem;
  final Function(int) onChangeAmount;
  const SupplementItemWidget({super.key, required this.onRemoveItem, required this.onChangeAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: _error ? const Border.fromBorderSide(BorderSide(color: AppColors.red45Percent,  width: 4)) : null,
        borderRadius: BorderRadius.circular(15),
        color: _error ? AppColors.white65Percent : AppColors.white85Percent,),
      margin:  const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ameer',
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Icon(Icons.cancel_outlined, size: Dimens.heightXSmall),
                ),
              ],
            ),
          ),
          Text(AppLocalizations.of(context)!.amount, style: const TextStyle(color: AppColors.yellowishGreen, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w700)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
            height: Dimens.heightSmall - 15,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '2',
                        selection: TextSelection.collapsed(
                          offset: 0,
                        ),
                      ),
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                        borderSide: BorderSide(color: AppColors.silver, width: 1),
                      ),
                    ),
                    onChanged: (amount) {

                    },
                  ),
                ),
                const SizedBox(width: Dimens.widthXXXXSmall),
                Expanded(
                  flex: 2,
                  child: true
                      ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingSmall),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(11)),
                        border: Border.fromBorderSide(
                            BorderSide(color: AppColors.silver, width: 1))),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
                      value: 'Hamza',
                      onChanged: (String? unitName) {},
                      items: ['Ameer', 'Hamza']
                          .map<DropdownMenuItem<String>>(
                            (item) => DropdownMenuItem(
                          value: item,
                          alignment: Alignment.center,
                          child: SizedBox(
                            child: Text(
                              item,
                              // overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: Dimens.fontSizeNormal,
                              ),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  )
                      : Text(
                      AppLocalizations.of(context)!.grames.toLowerCase()),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimens.widthXXXXSmall),
        ],
      ),
    );
  }

}