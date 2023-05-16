import 'package:flutter/material.dart';
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
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    isChecked = widget.checkboxValue;

    return Card(
      elevation: 4,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: Dimens.marginLarge),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  overflow: widget.overflow ?? TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeNormal,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    fillColor: MaterialStateProperty.all(Colors.grey[400]),
                    checkColor: Colors.black,
                    side: const BorderSide(width: 1, color: Colors.black,),
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                        widget.onChangedCheckbox.call();
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}