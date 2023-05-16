import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

// TODO: Set the right icon.
// TODO: if it belongs to a multiselect widget, manage unselecting throw parent widget. Look NN app.
class CenteredIconBox extends StatefulWidget {
  final IconData icon;
  final Color colorSelected;
  final Function onClick;
  final bool isSelected;

  const CenteredIconBox({
    Key? key,
    required this.icon,
    required this.colorSelected,
    required this.onClick,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenteredIconBox();

}
class _CenteredIconBox extends State<CenteredIconBox> {
  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.colorSelected : Colors.grey[100],
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: () {
            widget.onClick.call();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal,),
            child: Icon(
              widget.icon,
              size: 29,
            ),
          ),
        ),
      ),
    );
  }

}