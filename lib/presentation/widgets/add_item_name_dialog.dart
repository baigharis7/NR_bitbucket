import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../infrastructure/helpers/toast_helper.dart';
import '../../infrastructure/utils/dimens.dart';

class AddItemNameDialog extends StatefulWidget {
  final String title;
  final Function(String) onNameChange;
  final Function onFinish;
  final Function onCancel;
  const AddItemNameDialog({super.key, required this.title, required this.onNameChange, required this.onFinish, required this.onCancel});

  @override
  State<AddItemNameDialog> createState() => _AddItemNameDialogState();
}

class _AddItemNameDialogState extends State<AddItemNameDialog> {
  final _itemNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: mediaQuerySize.width,
              height: mediaQuerySize.height/2.5,
              child: Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => widget.onCancel.call(),
                        icon: const Icon(Icons.clear,),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(
                        left: Dimens.marginNormal,
                        right: Dimens.marginNormal,
                        top: Dimens.marginNormal,
                      ),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeMedium,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.all(Dimens.marginNormal),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.write_here_hint,
                        ),
                        controller: _itemNameController,
                        onChanged: (foodName) => widget.onNameChange.call(foodName),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
              child: RoundedCustomButton(
                buttonText: AppLocalizations.of(context)!.save,
                onPressed: () {
                  if (_itemNameController.text == '') {
                    ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                  } else {
                    widget.onFinish.call();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}