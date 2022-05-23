import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/selectable_option.dart';

class AddFoodEventItem extends StatefulWidget {
  final FoodInEvent ingredient;
  final String currentLanguage;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;

  const AddFoodEventItem({
    Key? key,
    required this.ingredient,
    required this.currentLanguage,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.cookingMethodsInfoMaster
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodEventItem();
}

class _AddFoodEventItem extends State<AddFoodEventItem> {
  final _textController = TextEditingController();

  List<SimpleItem> findCookingMethodsForFood(String foodGroup) {

    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    final List<int> groupCookingMethods = widget.cookingMethodsMaster.cookingMethods.firstWhere(
            (cookingMethod) => cookingMethod.group == foodGroup,
        orElse: () => CookingMethod('1.3', [0, 1, 2, 3]),
    ).methods;
    final cookingMethodsInfo = groupCookingMethods.map((cookingMethodId) {
      String name;
      if (widget.currentLanguage == 'es') {
        name = widget.cookingMethodsInfoMaster.cookingMethodsInfo!.firstWhere((methodInfo) => methodInfo.id == cookingMethodId).es!;
      } else {
        name = widget.cookingMethodsInfoMaster.cookingMethodsInfo!.firstWhere((methodInfo) => methodInfo.id == cookingMethodId).en!;
      }
      return SimpleItem(name: name, id: cookingMethodId);
    });

    return cookingMethodsInfo.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ingredient.qty != 0) _textController.text = widget.ingredient.qty.toString();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge),
                child: Text('${AppLocalizations.instance.translate('quantity')}:')
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.only(right: Dimens.marginLarge),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _textController,

                  decoration: InputDecoration(
                    labelText: AppLocalizations.instance.translate('write_here_hint'),
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
          // TODO: Aquí va el tema de elegir las unidades, tengo que descubrir qué unidades hay que poner, y cómo, antes de nada
          child: const Text('Units', maxLines: 3,),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
          // TODO: Y aquí el tema de los métodos de cocinado, que sinceramente no me voy a poner ahora con ello.
          child: Column(
            children: [
              ...findCookingMethodsForFood(widget.foodGroup).map((cookingMethod) {
                return SelectableOption(
                    isSelected: widget.ingredient.cookingMethod == cookingMethod.id,
                    selectedItemsList: [widget.ingredient.cookingMethod],
                    name: cookingMethod.name,
                    onTap: (id) {
                      setState(() {
                        widget.ingredient.cookingMethod = id;
                      });
                    },
                    id: cookingMethod.id
                );
              })
            ],
          )
        ),
        ElevatedButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.pinkAccent),
          onPressed: () {
            if (_textController.text != '') {
              final foodEvent = FoodInEvent(
                  id: widget.ingredient.id,
                  qty: int.parse(_textController.text),
                  unit: 0,
                  cookingMethod: 0
              );
              Navigator.pop(context, foodEvent);
            }
          },
          child: const Text('Ya está', style: TextStyle(color: Colors.white),),
        )
      ],
    );
  }

}