import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: widget.isSelected ? widget.colorSelected : AppColors.floralWhite,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.border18)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.border18)),
        onTap: () {
          widget.onClick.call();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal,),
          child: Icon(
            widget.icon,
            size: 29,
            color: widget.isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

}