import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

class ScreenTopBar extends StatelessWidget {
  final DateTime? selectedDate;
  final String? title;
  final VoidCallback onBack;

  const ScreenTopBar({
    super.key,
    this.selectedDate,
    this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final backSize = sw * (28 / 360);
    final iconSize = backSize * 0.5;
    final titleFontSize = sw * (17 / 360);
    final hPadding = sw * (16 / 360);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: backSize,
              height: backSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9).withOpacity(0.80),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: iconSize,
                color: const Color(0xFF28421D),
              ),
            ),
          ),
          if (title != null)
            Text(
              title!,
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: titleFontSize,
                color: Colors.white,
              ),
            )
          else if (selectedDate != null)
            Text(
              DateFormat('EEE, MMM d yyyy').format(selectedDate!),
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: titleFontSize,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
