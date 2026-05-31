import 'package:flutter/material.dart';

/// Sticky bottom progress indicator for the onboarding flow.
/// Highlights [currentStep] (0-indexed) out of [totalSteps] with an
/// animated transition when the step changes.
class OnboardingProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressDots({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (i) {
          final isActive = i == currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
