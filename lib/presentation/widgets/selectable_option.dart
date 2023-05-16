import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

// TODO: Añadir argumento de Widget para ponerle botón y poder hacerlo genérico. Aplicarlo tb en ActivityFactor.
class SelectableOption extends StatefulWidget {
  final int selectedOption;
  final String name;
  final int id;
  final Function onTap;

  const SelectableOption({
    Key? key,
    required this.selectedOption,
    required this.name,
    required this.onTap,
    required this.id,
  }): super(key: key);

  @override
  State<SelectableOption> createState() => _SelectableOptionState();

}

class _SelectableOptionState extends State<SelectableOption> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTap.call(widget.id);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginSmall),
        decoration: BoxDecoration(color: widget.selectedOption == widget.id
            ? Colors.amber
            : Colors.transparent,
            border: Border.all(
              width: Dimens.borderNormal,
              color: widget.selectedOption == widget.id
                  ? Colors.amber
                  : Colors.transparent,
            ),
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20)),),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(Dimens.paddingSmall),
            child: Text(widget.name),
          ),
        ),
    );
  }

}