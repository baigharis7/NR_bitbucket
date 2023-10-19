import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextFieldGeneralQuest extends StatelessWidget {
  final String title;
  final Function onChanged;
  final bool isNumeric;
  final Color errorBorderColor;
  final int? value;
  final textController = TextEditingController();

  TextFieldGeneralQuest(
      {Key? key,
      required this.title,
      required this.onChanged,
      this.isNumeric = false,
        required this.errorBorderColor,
      required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (textController.text == '')
      textController.text = value.isNull() ? '' : value.toString();

    return Card(
      color: AppColors.snow,
      margin: const EdgeInsets.symmetric(
          horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
      elevation: 5.0,
      child: Container(decoration: BoxDecoration(border: Border.all(color: errorBorderColor, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(5)),),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    TextField(
                      keyboardType:
                          isNumeric ? TextInputType.number : TextInputType.text,
                      controller: textController,
                      decoration: const InputDecoration(),
                      onChanged: (value) {
                        if (textController.text != '') {
                          onChanged
                              .call(int.parse(textController.text.orEmpty()));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
