import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextImageCheckbox extends StatefulWidget {
  final String title;
  final Image image;
  final bool isSelected;
  final Function onPressed;

  const TextImageCheckbox({
    Key? key,
    required this.title,
    required this.image,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextImageCheckbox();

}

class _TextImageCheckbox extends State<TextImageCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    isChecked = widget.isSelected;

    return Card(
      child: InkWell(
        onTap: () => widget.onPressed.call(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeNormal,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: widget.image,
                ),
              ),
              Expanded(
                flex: 1,
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
                        widget.onPressed.call();
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}