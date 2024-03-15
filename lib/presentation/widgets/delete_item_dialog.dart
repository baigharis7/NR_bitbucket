import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteItemDialog extends StatelessWidget {
  final String? titleText;
  final Function onDelete;
  final Function onCancel;
  const DeleteItemDialog({super.key, this.titleText, required this.onDelete, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), contentPadding: EdgeInsets.zero, children: [
      Container(
        height: MediaQuery.of(context).size.height/3.5,
        margin: const EdgeInsets.all(Dimens.marginNormal),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(bottom: Dimens.marginXXXLarge), alignment: Alignment.centerRight, child: InkWell(onTap: () => onCancel.call(), child: const Icon(Icons.cancel_outlined))),
          Text(titleText ?? AppLocalizations.of(context)!.remove_item),
          SizedBox(
            height: Dimens.heightNormal,
            child: Row(children: [
              Expanded(child: RoundedCustomButton(buttonText: AppLocalizations.of(context)!.remove, onPressed: () => onDelete.call())),
              const SizedBox(width: Dimens.heightXXSmall),
              Expanded(child: RoundedCustomButton(buttonText: AppLocalizations.of(context)!.keep, onPressed: () => onCancel.call())),
            ],),
          ),
        ],),
      ),
    ],);
  }

}