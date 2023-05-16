import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextRadioButtonExpansible extends StatelessWidget {
  final String title;
  final String explanation;
  final bool isSelected;
  final Function onPressed;

  const TextRadioButtonExpansible({
    Key? key,
    required this.title,
    required this.explanation,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => onPressed.call(),
        child: Container(
          margin: const EdgeInsets.only(top: Dimens.marginLarge, bottom: Dimens.marginLarge),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal),
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeNormal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.only(right: Dimens.marginNormal),
                      child: Container(
                        height: 21,
                        width: 21,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: Dimens.borderSmall,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              if (isSelected && explanation != '') Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginSmall),
                child: Text(
                  explanation,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}