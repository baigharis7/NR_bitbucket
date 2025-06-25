import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double width;
  final double dashWidth;
  final double dashHeight;
  final double dashSpacing;
  final Color color;

  const DashedLine({
    required this.width,
    this.dashWidth = 5,
    this.dashHeight = 1,
    this.dashSpacing = 3,
    this.color = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Total number of dashes that can fit
    final int dashCount = (width / (dashWidth + dashSpacing)).floor();

    return SizedBox(
      width: width,
      height: dashHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dashCount, (_) {
          return SizedBox(
            width: dashWidth,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color),
            ),
          );
        }),
      ),
    );
  }
}
