import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextIconBox extends StatefulWidget {
  final String title;
  final Color? color;
  final bool isSelected;
  final Function onAdd;
  final Function? onWatch;
  final bool? showAddButton;
  final bool? showWatchButton;
  final IconData? icon;
  final bool isCentered;

  const TextIconBox({
    Key? key,
    required this.title,
    this.color = Colors.grey,
    this.isSelected = false,
    required this.onAdd,
    this.onWatch,
    this.showAddButton = false,
    this.showWatchButton = false,
    this.icon,
    this.isCentered = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextIconBox();
}

class _TextIconBox extends State<TextIconBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.color : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Container(
              alignment: widget.isCentered ? Alignment.center : Alignment.centerLeft,
              margin: widget.showAddButton != null && widget.showAddButton! ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title),
                  if (widget.showAddButton!) SizedBox(
                    child: IconButton(
                      onPressed: () => widget.onAdd.call(),
                      icon: widget.icon != null ? Icon(widget.icon, size: 30,) : const Icon(Icons.add_circle_outline_sharp, size: 26,),
                    ),
                  )
                ],
              ),
            ),
            if (widget.showWatchButton!) Container(
              alignment: Alignment.centerLeft,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 26),
                  onPressed: () => widget.onWatch?.call(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}