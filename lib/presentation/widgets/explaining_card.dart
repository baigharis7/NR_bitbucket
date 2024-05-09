import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ExplainingCard extends StatelessWidget {
  final String upperText;
  final Function? onHideCard;
  final String? lowerText;
  final String? buttonText;
  final Function? onPressedButton;

  const ExplainingCard({
    Key? key,
    required this.upperText,
    this.onHideCard,
    this.lowerText,
    this.buttonText,
    this.onPressedButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(Dimens.marginNormal),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(
          width: 1, 
          color: Colors.blue[500]!,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(Dimens.marginNormal),
                  child: Text(
                    upperText,
                    style: TextStyle(
                      color: Colors.blue[500]!,
                    ),
                  ),
                ),
                if (buttonText != null) Container(
                  margin: const EdgeInsets.all(Dimens.marginNormal),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                    ),
                    onPressed: () => onPressedButton?.call(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: Text(
                              buttonText.orEmpty(),
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.add_circle_outline_sharp,
                            size: 28,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (lowerText != null) Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, bottom: Dimens.marginNormal),
                  child: Text(
                    lowerText.orEmpty(),
                    style: TextStyle(
                      color: Colors.blue[600]!,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (!onHideCard.isNull()) Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: Dimens.marginNormal, bottom: Dimens.marginNormal),
              child: IconButton(
                onPressed: () => onHideCard?.call(),
                icon: Icon(
                  Icons.clear,
                  size: 28,
                  color: Colors.blue[500]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}