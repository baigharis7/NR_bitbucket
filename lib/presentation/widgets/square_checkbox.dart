import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class SquareCheckbox extends StatefulWidget {
  final bool isChecked;
  final Function onChanged;
  final double? height;
  final double? width;
  final Color? color;

  const SquareCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SquareCheckboxState();

}

class _SquareCheckboxState extends State<SquareCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 28,
      width: widget.width ?? 28,
      margin: const EdgeInsets.all(Dimens.marginSmall),
      decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: widget.color ?? Colors.blue,
          ),
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            widget.onChanged.call();
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            color: widget.isChecked ? widget.color ?? Colors. blue : Colors.transparent,
          ),
        ),
      ),
    );
  }

}