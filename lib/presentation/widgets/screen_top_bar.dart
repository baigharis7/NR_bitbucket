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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9).withOpacity(0.80),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: Color(0xFF28421D),
                ),
              ),
            ),
          ),
          if (title != null)
            Text(
              title!,
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            )
          else if (selectedDate != null)
            Text(
              DateFormat('EEE, MMM d yyyy').format(selectedDate!),
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
