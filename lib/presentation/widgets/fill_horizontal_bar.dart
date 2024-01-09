import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

class FillHorizontalBar extends StatelessWidget {
  final double? fractionToFill;
  final double? height;
  final Color? backgroundBarColor;
  final Color? fillColor;
  final bool applyBoxShadow;

  const FillHorizontalBar({
    Key? key,
    required this.fractionToFill,
    this.height,
    this.backgroundBarColor,
    this.fillColor,
    this.applyBoxShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            SizedBox(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.00,),
                  color: backgroundBarColor == null ? Colors.grey[200] : Colors.teal[100],
                  shape: BoxShape.rectangle,
                  boxShadow: applyBoxShadow
                      ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), //color of shadow
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    )
                  ]
                    : [],
                ),
                height: height ?? 15,
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fractionToFill,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: fillColor ?? AppColors.mountainMeadow,
                            borderRadius: BorderRadius.circular(20.00,),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

}