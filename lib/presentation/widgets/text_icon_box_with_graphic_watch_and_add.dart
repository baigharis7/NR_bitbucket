import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class TextIconBoxWithGraphicWatchAndAdd extends StatelessWidget {
  final String title;
  final Color? color;
  final bool isSelected;
  final Function onAdd;
  final Function onWatch;
  final int? calories;
  final Widget? graphic;

  const TextIconBoxWithGraphicWatchAndAdd({
    Key? key,
    required this.title,
    this.color = Colors.grey,
    this.isSelected = false,
    required this.onAdd,
    required this.onWatch,
    this.calories,
    this.graphic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: Dimens.marginSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(title),
                      Image.asset('assets/icon/sport_icon.png', height: 25, width: 25,),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    height: 30,
                    width: 30,
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline_sharp, size: 26),
                      onPressed: () => onAdd.call(),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
          //   alignment: Alignment.centerLeft,
          //   child: Text('$calories kcal'),
          // ),
          if (graphic != null) Container(
            child: graphic,
          ),
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, size: 26),
              onPressed: () => onWatch.call(),
            ),
          )
        ],
      ),
    );
  }

}