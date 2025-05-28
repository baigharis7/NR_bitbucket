import 'package:flutter/material.dart';

class FillVerticalBar extends StatelessWidget {
  final double? fractionToFill;
  final double? width;
  final Color? barColor;

  const FillVerticalBar({Key? key, required this.fractionToFill, this.width, this.barColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.00,),
                color: Colors.transparent,
                shape: BoxShape.rectangle,
              ),
              width: width ?? 15,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.00,),
                      shape: BoxShape.rectangle,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      heightFactor: fractionToFill,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor ?? Colors.white30,
                          borderRadius: BorderRadius.circular(20.00,),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

}