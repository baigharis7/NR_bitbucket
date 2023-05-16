import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class SelectableOptionsList extends StatefulWidget {
  final List itemList;
  final List selectedItemsList;
  final Function onTapAction;

  const SelectableOptionsList({Key? key, required this.itemList, required this.selectedItemsList, required this.onTapAction}): super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectableOptionsState();
}

class _SelectableOptionsState extends State<SelectableOptionsList> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimens.marginNormal,
        Dimens.zero,
        Dimens.marginNormal,
        Dimens.marginLarge,
      ),
      child: ListView.builder(
        itemCount: widget.itemList.length,
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return Container(
            margin: const EdgeInsets.all(Dimens.marginSmall),
            decoration: BoxDecoration(color: widget.selectedItemsList.contains(widget.itemList[index].id)
                ? Colors.amber
                : Colors.transparent,
                border: Border.all(
                  width: Dimens.borderNormal,
                  color: widget.selectedItemsList.contains(widget.itemList[index].id)
                      ? Colors.amber
                      : Colors.transparent,
                ),
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.onTapAction(widget.itemList[index].id!);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Dimens.paddingSmall),
                child: Text(widget.itemList[index].name.toString().orEmpty()),
              ),
            ),
          );
        },
      ),
    );
  }

}