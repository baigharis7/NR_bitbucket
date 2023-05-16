import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextValueIconBox extends StatefulWidget {
  final String title;
  final Color? color;
  final bool isSelected;
  final Function onClick;
  final IconData? icon;
  final bool isCentered;
  final int? value;
  final String? unit;

  const TextValueIconBox({
    Key? key,
    required this.title,
    this.color = Colors.grey,
    this.isSelected = false,
    required this.onClick,
    this.icon,
    this.isCentered = true,
    this.value,
    this.unit,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextValueIconBox();
}

class _TextValueIconBox extends State<TextValueIconBox> {
  @override
  Widget build(BuildContext context) {

    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall),
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.color : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              widget.onClick.call();
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
            child: Container(
              alignment: widget.isCentered ? Alignment.center : Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title),
                  Text(widget.value == null || widget.value == -1 ? '' : '${widget.value} ${widget.unit}'),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: widget.icon != null ? Icon(widget.icon) : const Icon(Icons.add_circle),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}