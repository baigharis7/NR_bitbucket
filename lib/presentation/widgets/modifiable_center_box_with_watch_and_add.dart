import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ModifiableCenterBoxWithWatchAndAdd extends StatelessWidget {
  final Widget centerWidget;
  final Function onWatchPressed;
  final Function onAddPressed;
  final String title;

  const ModifiableCenterBoxWithWatchAndAdd({
    Key? key,
    required this.centerWidget,
    required this.onWatchPressed,
    required this.onAddPressed,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { onWatchPressed.call(); },
      child: Card(
        child: SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginNormal),
                child: Text(title),
              ),
              Container(
                alignment: Alignment.center,
                child: centerWidget,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      child: IconButton(
                        onPressed: () => onWatchPressed.call(),
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 26, color: Colors.black,),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () => onAddPressed.call(),
                      icon: const Icon(Icons.add_circle_outline_sharp, size: 26, color: Colors.black),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}