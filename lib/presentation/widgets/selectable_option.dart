import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

// TODO: Añadir argumento de Widget para ponerle botón y poder hacerlo genérico. Aplicarlo tb en ActivityFactor.
class SelectableOption extends StatefulWidget {
  bool isSelected;
  final List selectedItemsList;
  final String name;
  final int id;
  final Function onTap;

  SelectableOption({Key? key, required this.isSelected, required this.selectedItemsList, required this.name, required this.onTap, required this.id}): super(key: key);

  @override
  State<SelectableOption> createState() => _SelectableOptionState();

}

class _SelectableOptionState extends State<SelectableOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isSelected = !widget.isSelected;
          widget.onTap.call(widget.id);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginSmall),
        decoration: BoxDecoration(color: widget.isSelected
            ? Colors.amber
            : Colors.transparent,
            border: Border.all(
              width: Dimens.borderNormal,
              color: widget.isSelected
                  ? Colors.amber
                  : Colors.transparent,
            ),
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(Dimens.paddingSmall),
            child: Text(widget.name),
          ),
        ),
    );
  }

}