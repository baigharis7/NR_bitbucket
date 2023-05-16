import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class AddLiquidEventDialog extends StatefulWidget {
  final LiquidInEvent liquid;
  final String currentLanguage;

  const AddLiquidEventDialog({Key? key, required this.liquid, required this.currentLanguage}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddLiquidEventDialogState();

}

class _AddLiquidEventDialogState extends State<AddLiquidEventDialog> {
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.liquid.qty != 0) _quantityController.text = widget.liquid.qty.toString();
    LiquidInEvent liquid = LiquidInEvent(id: widget.liquid.id, qty: 0);
    final mediaQuerySize = MediaQuery.of(context).size;

    if (liquid.qty != 0) _quantityController.text = liquid.qty.toString();

    return SizedBox(
      width: mediaQuerySize.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge),
                child: Text('${AppLocalizations.of(context)!.quantity}:'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.only(bottom: Dimens.marginNormal),
                  margin: const EdgeInsets.only(right: Dimens.marginLarge, left: Dimens.marginNormal),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.write_here_hint,
                      alignLabelWithHint: true,
                    ),
                    onChanged: (qty) => liquid.qty = int.parse(qty),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(bottom: Dimens.marginNormal),
                  margin: const EdgeInsets.only(
                      right: Dimens.marginLarge,
                      left: Dimens.marginSmall,
                      top: Dimens.marginXLarge,
                  ),
                  child: Text(AppLocalizations.of(context)!.ml),
                ),
              )
            ],
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () {
              if (_quantityController.text != '' && _quantityController.text != '0') {
                final liquidInEvent = LiquidInEvent(
                  id: liquid.id,
                  qty: liquid.qty,
                );
                Navigator.pop(context, liquidInEvent);
              } else {
                ToastHelper().showToast(text: AppLocalizations.of(context)!.missing_fieds_food_event);
              }
            }, child: Text(AppLocalizations.of(context)!.finish, style: const TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}