import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class SupplementItemWidget extends StatefulWidget {
  final String title;
  final String amount;
  final List<String> units;
  final String? unit;
  final VoidCallback onRemoveItem;
  final Function(String) onChangeAmount;
  final bool showValidation;
  const SupplementItemWidget({super.key, required this.title, required this.amount, required this.units, required this.unit, required this.onRemoveItem, required this.onChangeAmount, this.showValidation = false});

  @override
  State<SupplementItemWidget> createState() => _SupplementItemWidgetState();
}

class _SupplementItemWidgetState extends State<SupplementItemWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.amount;
  }

  @override
  void didUpdateWidget(covariant SupplementItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.amount) {
      _controller.text = widget.amount;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showError = widget.showValidation && widget.amount.isEmpty;

    return Column(
      children: [
      Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.white85Percent,),
      margin: const EdgeInsets.only(top: Dimens.marginSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                  ),
                ),
                InkWell(
                  onTap: widget.onRemoveItem,
                  child: const Icon(Icons.cancel_outlined, size: 26, color: AppColors.yellowishGreen),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingSmall),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(11)),
                        borderSide: BorderSide(color: showError ? AppColors.errorRed : AppColors.silver, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(11)),
                        borderSide: BorderSide(color: showError ? AppColors.errorRed : AppColors.silver, width: 1),
                      ),
                    ),
                    onChanged: widget.onChangeAmount,
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
                      value: widget.unit,
                      onChanged: (String? unitName) {},
                      items: widget.units
                          .map<DropdownMenuItem<String>>(
                            (item) => DropdownMenuItem(
                          value: item,
                          alignment: Alignment.center,
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: Dimens.fontSizeNormal,
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
          if (showError) Padding(
            padding: const EdgeInsets.only(top: Dimens.marginSmall),
            child: Text(AppLocalizations.of(context)!.please_enter_amount, style: const TextStyle(color: AppColors.errorRed, fontSize: Dimens.fontSizeSmall)),
          ),
        ],
      ),
    ),
    ],
    );
  }

}
