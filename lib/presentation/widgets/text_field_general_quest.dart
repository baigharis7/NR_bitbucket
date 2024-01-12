import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextFieldGeneralQuest extends StatefulWidget {
  final String title;
  final Function onChanged;
  final bool isNumeric;
  final Color errorBorderColor;
  final int? value;

  const TextFieldGeneralQuest(
      {Key? key,
      required this.title,
      required this.onChanged,
      this.isNumeric = false,
        required this.errorBorderColor,
      required this.value})
      : super(key: key);

  @override
  State<TextFieldGeneralQuest> createState() => _TextFieldGeneralQuestState();
}

class _TextFieldGeneralQuestState extends State<TextFieldGeneralQuest> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (textController.text == '') {
      textController.text = widget.value.isNull() ? '' : widget.value.toString() == '-1' ? '' : widget.value.toString();
    }

    return Card(
      color: AppColors.snow,
      margin: const EdgeInsets.symmetric(
          horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
      elevation: 5.0,
      child: Container(decoration: BoxDecoration(border: Border.all(color: widget.errorBorderColor, width: 2),
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
                    Text(widget.title),
                    TextField(
                      keyboardType:
                          widget.isNumeric ? TextInputType.number : TextInputType.text,
                      controller: textController,
                      decoration: const InputDecoration(),
                      onChanged: (value) {
                        widget.onChanged.call(int.parse(textController.text.toString().isEmpty ? '-1' : textController.text));
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
