import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

class ScreenTopBar extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onBack;

  const ScreenTopBar({
    super.key,
    required this.selectedDate,
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9).withOpacity(0.80),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Color(0xFF28421D),
              ),
            ),
          ),
          if (selectedDate != null)
            Text(
              DateFormat('EEE, MMM d yyyy').format(selectedDate!),
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
