import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextFieldGeneralQuest extends StatefulWidget {
  final String title;
  final Function onChanged;
  final bool isNumeric;
  final Color errorBorderColor;
  final double? value;

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
      textController.text = widget.value.orZero() <= 0 ? '' : widget.value.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize17, color: Colors.white)),
        TextField(
          keyboardType:
              widget.isNumeric ? TextInputType.number : TextInputType.text,
          controller: textController,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            focusColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
          onChanged: (value) {
            widget.onChanged.call(textController.text.toString().isEmpty ? '-1' : textController.text);
          },
        ),
      ],
    );
  }
}
