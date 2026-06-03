import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../infrastructure/helpers/app_text_styles.dart';

class TextFieldGeneralQuest extends StatefulWidget {
  final String title;
  final Function onChanged;
  final bool isNumeric;
  final bool integerOnly;
  final Color errorBorderColor;
  final double? value;
  final String? Function(String?)? validator;

  /// When true, uses darker colors so it reads correctly against a light
  /// (floralWhite) card background — used by the onboarding flow.
  final bool dark;

  const TextFieldGeneralQuest(
      {Key? key,
      required this.title,
      required this.onChanged,
      this.isNumeric = false,
      this.integerOnly = false,
        required this.errorBorderColor,
      required this.value,
      this.validator,
      this.dark = false})
      : super(key: key);

  @override
  State<TextFieldGeneralQuest> createState() => _TextFieldGeneralQuestState();
}

class _TextFieldGeneralQuestState extends State<TextFieldGeneralQuest> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (textController.text == '') {
      if (widget.value.orZero() <= 0) {
        textController.text = '';
      } else if (widget.integerOnly) {
        textController.text = widget.value!.round().toString();
      } else {
        textController.text = widget.value.toString();
      }
    }

    final fg =
        widget.dark ? AppColors.yellowishGreen : Colors.white;
    final borderColor =
        widget.dark ? AppColors.yellowishGreen : AppColors.whit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize17, color: fg)),
        TextFormField(
          keyboardType:
              widget.isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: widget.integerOnly
              ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
              : null,
          controller: textController,
          cursorColor: fg,
          style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal, color: fg),
          decoration: InputDecoration(
            focusColor: fg,
            contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor, width: 1)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fg, width: 2)),
            errorMaxLines: 2,
          ),
          validator: widget.validator,
          onChanged: (value) {
            widget.onChanged.call(textController.text);
          },
        ),
      ],
    );
  }
}
