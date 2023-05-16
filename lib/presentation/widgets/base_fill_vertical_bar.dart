import 'package:flutter/material.dart';

class BaseFillVerticalBar extends StatelessWidget {
  final double? fractionToFill;
  final double? width;

  const BaseFillVerticalBar({Key? key, required this.fractionToFill, this.width = 15.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.00,),
                shape: BoxShape.rectangle,
              ),
              width: width,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.white30,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      heightFactor: fractionToFill,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
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