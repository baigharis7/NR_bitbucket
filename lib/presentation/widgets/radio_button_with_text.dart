import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButtonWithText extends StatelessWidget {
  final String text;
  final int value;
  final int groupValue;
  final Function(int) onConversionFactorChange;
  const RadioButtonWithText({super.key, required this.text, required this.value, required this.groupValue, required this.onConversionFactorChange});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onConversionFactorChange.call(value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact,
              value: value,
              groupValue: groupValue,
              onChanged: (val) => onConversionFactorChange.call(value),),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

}