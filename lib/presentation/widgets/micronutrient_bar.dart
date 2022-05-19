import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class MicronutrientBar extends StatelessWidget {
  final String name;
  final double micronutrientSoFar;
  final double rdaMicronutrient;

  const MicronutrientBar(this.name, this.micronutrientSoFar, this.rdaMicronutrient);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: Dimens.marginSmall),
              child: Expanded(
                  flex: 1,
                  child: Text(name),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.05,
            ),
            Container(
              width: constraints.maxWidth * 0.6,
              height: 10,
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      color: const Color.fromRGBO(220, 220, 220, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: rdaMicronutrient,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.05,
            ),
          ],
        );
      },
    );
  }
}
