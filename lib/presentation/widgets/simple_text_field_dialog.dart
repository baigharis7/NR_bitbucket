import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class SimpleTextFieldDialog extends StatelessWidget {
  final String title;
  final Function onChanged;
  final bool isNumeric;
  final int? value;
  final textController = TextEditingController();

  SimpleTextFieldDialog({Key? key, required this.title, required this.onChanged, this.isNumeric = false, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (textController.text == '') textController.text = value.isNull() ? '' : value.toString();

    return SimpleDialog(
      title: Center(
          child: Text(title),
      ),
      children: [
        Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                  child: TextField(
                    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.write_here_hint,
                    ),
                    onChanged: (value) => onChanged.call(value),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    if (textController.text != '') {
                      onChanged.call(int.parse(textController.text.orEmpty()));
                      Navigator.pop(context);
                    }
                    },
                  icon: const Icon(
                      Icons.arrow_circle_right_rounded,
                  ),
                ),
              )
            ],
        )
      ],
    );
  }

}