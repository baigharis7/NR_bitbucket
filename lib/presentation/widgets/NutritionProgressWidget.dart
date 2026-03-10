import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/sugar_&_fiber_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/methods_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/view/energy_balance_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ingested_spent_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import 'ani_nutri_progress_bar_widget.dart';
import 'nutrient_element_widget.dart';

class NutritionProgressWidget extends StatefulWidget {
  final EnergyModel? energyModel;
  final List<NutrientsModel> nutrientsList;
  final DateTime? selectedDate;
  final SugarAndFiberModel? sugarAndFiberModel;

  const NutritionProgressWidget({
    super.key,
    required this.energyModel,
    required this.nutrientsList,
    this.selectedDate,
    this.sugarAndFiberModel,
  });

  @override
  _NutritionProgressWidgetState createState() =>
      _NutritionProgressWidgetState();
}

class _NutritionProgressWidgetState extends State<NutritionProgressWidget> {
  static const double _logoSize = 60;
  static const double _bumpPeek = 22; // how much the bump peeks above the card top edge

  Widget _buildDataMetric(double consumed, double total, String unit) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${consumed.ceil()}',
            style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize15),
          ),
          TextSpan(
            text: unit,
            style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
          ),
          TextSpan(
            text: ' / ',
            style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
          ),
          TextSpan(
            text: '${total.toInt()}',
            style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize15),
          ),
          TextSpan(
            text: unit,
            style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
          ),
        ],
      ),
    );
  }

  Widget _buildSugarFiberColumn({
    required double consumed,
    required double total,
    required String title,
    Color? progressColor,
  }) {
    double progress = total > 0 ? (consumed / total).clamp(0.0, 1.0) * 100 : 0.0;
    return Column(
      children: [
        _buildDataMetric(consumed, total, 'g'),
        AnimatedNutrientProgressBarWidget(
          percent: progress,
          width: Dimens.widthNormal,
          height: Dimens.height12,
          color: progressColor,
        ),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.energyModel == null) return const SizedBox.shrink();
    final double totalConsumed = double.parse(
        (widget.energyModel!.rawKcalTaken - widget.energyModel!.spentKcal)
            .toString());
    final double remaining = double.parse(
        (widget.energyModel!.totalKcal - totalConsumed).toString());
    final double percent = widget.energyModel!.totalKcal > 0
        ? (totalConsumed / widget.energyModel!.totalKcal)
        : 0.0;
    final double percentage = percent * 100;
    final colors = (percentage >= Constants.PERCENTAGE_110 &&
            percentage <= Constants.PERCENTAGE_115)
        ? AppColors.mustardYellow
        : percentage > Constants.PERCENTAGE_115
            ? AppColors.red
            : AppColors.mountainMeadow;

    final sugarConsumed = widget.sugarAndFiberModel?.totalSugarConsumed ?? 0.0;
    final sugarTotal = widget.sugarAndFiberModel?.requiredSugar ?? 0.0;
    final fiberConsumed = widget.sugarAndFiberModel?.totalFiberConsumed ?? 0.0;
    final fiberTotal = widget.sugarAndFiberModel?.requiredFiber ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: _bumpPeek),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card background with bump
          Positioned.fill(
            top: -_bumpPeek,
            child: CustomPaint(
              painter: _BumpCardPainter(
                color: const Color(0xFF28421D).withOpacity(0.76),
                borderRadius: Dimens.border15,
                bumpHalfWidth: (_logoSize / 2) + 14,
                bumpPeek: _bumpPeek,
                horizontalMargin: Dimens.marginNormal,
              ),
            ),
          ),
          // Content
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Space below bump for logo to sit
                SizedBox(height: _logoSize - _bumpPeek - 20),
                // Info icon row (top-right)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, EnergyBalanceDetailScreen.routeName,
                          arguments: {'energyModel': widget.energyModel, 'selectedDate': widget.selectedDate}),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: Image.asset('assets/images/info.png'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Sugar / Fiber row - center aligned
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSugarFiberColumn(
                          consumed: sugarConsumed,
                          total: sugarTotal,
                          title: AppLocalizations.of(context)!.sugar,
                          progressColor: MethodsHelper.getAverageInPercentage(consumed: sugarConsumed, total: sugarTotal) < 180 ? AppColors.mustardYellow : AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 68),
                      Expanded(
                        child: _buildSugarFiberColumn(
                          consumed: fiberConsumed,
                          total: fiberTotal,
                          title: AppLocalizations.of(context)!.fiber,
                          progressColor: MethodsHelper.getAverageInPercentage(consumed: fiberConsumed, total: fiberTotal) < 180 ? AppColors.lightGreen : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Consumed / Donut / Burned row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: IngestedSpentWidget(
                            svg: 'assets/svg/fork_spoon.svg',
                            title: AppLocalizations.of(context)!.kcal_ingested_two_line,
                            value: widget.energyModel!.rawKcalTaken.orZero()),
                      ),
                      Expanded(
                        child: Center(
                          child: CircularPercentIndicator(
                            radius: 75.5,
                            animation: true,
                            animationDuration: 500,
                            lineWidth: Dimens.width18,
                            percent: percent.clamp(0.0, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${remaining.clamp(0, widget.energyModel!.totalKcal * 1).toInt()}',
                                  style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSize35, color: Colors.white),
                                ),
                                Text(
                                  'KCAL OF',
                                  style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSize11, color: Colors.white),
                                ),
                                Text(
                                  '${widget.energyModel!.totalKcal}',
                                  style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSizeNormal, color: Colors.white),
                                ),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: colors,
                            backgroundColor: Colors.white10,
                            curve: Curves.linear,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: IngestedSpentWidget(
                            svg: 'assets/svg/flame.svg',
                            title: AppLocalizations.of(context)!.spent_kcal_two_line,
                            value: widget.energyModel!.spentKcal.orZero()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Macronutrient bars
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ...widget.nutrientsList.map(
                        (nutrient) {
                          final double nPercent =
                              (nutrient.quantityConsumed / nutrient.rda);
                          final double nPercentage = nPercent * 100;
                          final color = (nPercentage >= Constants.PERCENTAGE_110 &&
                                  nPercentage <= Constants.PERCENTAGE_115)
                              ? AppColors.mustardYellow
                              : nPercentage > Constants.PERCENTAGE_115
                                  ? AppColors.red
                                  : AppColors.mountainMeadow;
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 3.5,
                            child: NutrientElementWidget(
                              label: nutrient.nutrientInfoMaster.translate(context),
                              current: nutrient.quantityConsumed,
                              goal: nutrient.rda.toDouble(),
                              unit: nutrient.unit.orEmpty(),
                              progressColor: color,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logo centered in the bump
          Positioned(
            top: -_bumpPeek + 14,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/images/logo_.png', width: _logoSize, height: _logoSize, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a rounded rectangle card with a smooth bezier curve tab at the top center.
/// Matches the Figma SVG shape: a curved notch that rises to hold the logo.
class _BumpCardPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double bumpHalfWidth;
  final double bumpPeek;
  final double horizontalMargin;

  _BumpCardPainter({
    required this.color,
    required this.borderRadius,
    required this.bumpHalfWidth,
    required this.bumpPeek,
    required this.horizontalMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cardLeft = horizontalMargin;
    final cardRight = size.width - horizontalMargin;
    final cx = size.width / 2;

    // Card top edge (where the flat part of the rectangle starts)
    final cardTop = bumpPeek;
    final cardBottom = size.height;

    // Bezier control point ratios derived from the Figma SVG path
    // Left curve: from (cx - halfW, cardTop) up to (cx, 0)
    // Right curve: from (cx, 0) down to (cx + halfW, cardTop)
    final hw = bumpHalfWidth;

    final path = Path();

    // Start at top-left corner (after border radius)
    path.moveTo(cardLeft + borderRadius, cardTop);

    // Top edge left side → approach the bump
    path.lineTo(cx - hw, cardTop);

    // Left side of bump: curve up to peak
    path.cubicTo(
      cx - hw * 0.73, cardTop - bumpPeek * 0.62,  // cp1
      cx - hw * 0.38, cardTop - bumpPeek,           // cp2
      cx, cardTop - bumpPeek,                        // peak center
    );

    // Right side of bump: curve down from peak
    path.cubicTo(
      cx + hw * 0.38, cardTop - bumpPeek,           // cp1
      cx + hw * 0.73, cardTop - bumpPeek * 0.62,    // cp2
      cx + hw, cardTop,                               // back to card top
    );

    // Top edge right side
    path.lineTo(cardRight - borderRadius, cardTop);

    // Top-right corner
    path.quadraticBezierTo(cardRight, cardTop, cardRight, cardTop + borderRadius);

    // Right edge
    path.lineTo(cardRight, cardBottom - borderRadius);

    // Bottom-right corner
    path.quadraticBezierTo(cardRight, cardBottom, cardRight - borderRadius, cardBottom);

    // Bottom edge
    path.lineTo(cardLeft + borderRadius, cardBottom);

    // Bottom-left corner
    path.quadraticBezierTo(cardLeft, cardBottom, cardLeft, cardBottom - borderRadius);

    // Left edge
    path.lineTo(cardLeft, cardTop + borderRadius);

    // Top-left corner
    path.quadraticBezierTo(cardLeft, cardTop, cardLeft + borderRadius, cardTop);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _BumpCardPainter) return true;
    return color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius ||
        bumpHalfWidth != oldDelegate.bumpHalfWidth ||
        bumpPeek != oldDelegate.bumpPeek;
  }
}
