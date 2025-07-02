import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextCheckboxBox extends StatefulWidget {
  final String title;
  final bool checkboxValue;
  final Function onChangedCheckbox;
  final TextOverflow? overflow;

  const TextCheckboxBox({
    Key? key,
    required this.title,
    required this.checkboxValue,
    required this.onChangedCheckbox,
    this.overflow,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextCheckboxBoxState();
}

class _TextCheckboxBoxState extends State<TextCheckboxBox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    _isChecked = widget.checkboxValue;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  overflow: widget.overflow ?? TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: Dimens.fontSize15,
                    color: AppColors.yellowishGreen,
                  ),
                ),
              ),
              Checkbox(
                fillColor: MaterialStateProperty.all(Colors.grey[400]),
                checkColor: AppColors.yellowishGreen,
                side: const BorderSide(width: 1, color: AppColors.yellowishGreen,),
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                    widget.onChangedCheckbox.call();
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.cloudyGrey, height: 1, thickness: 1,),
      ],
    );
  }

}