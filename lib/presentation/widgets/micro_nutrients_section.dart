import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrients_section.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class MicroNutrientsSection extends StatefulWidget {
  final List<NutrientsModel> micronutrients;
  final List<NutrientsModel> temporaryMicronutrients;
  final List<NutrientsModel> filteredNutrientsLess15RDA;
  final List<int>? objectives;
  final DateTime? selectedDate;
  const MicroNutrientsSection({super.key, required this.micronutrients, required this.temporaryMicronutrients, required this.filteredNutrientsLess15RDA, this.objectives, this.selectedDate});

  @override
  State<MicroNutrientsSection> createState() => _MicroNutrientsSectionState();
}

class _MicroNutrientsSectionState extends State<MicroNutrientsSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title bar with collapsible arrow
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            margin: const EdgeInsets.only(top: Dimens.marginSmall),
            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.micronutrientss,
                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isExpanded ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 22),
                ),
                const Spacer(),
                // GestureDetector wraps the visible icon area with a wider
                // hit target so taps adjacent to the 18×18 icon don't fall
                // through to the parent expansion handler. behavior: opaque
                // wins the gesture arena over the parent on its full bounds.
                // The icon stays visually 18×18 pinned to the right.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: {'micronutrients': widget.micronutrients, 'selectedDate': widget.selectedDate}),
                  child: SizedBox(
                    width: 44,
                    height: 32,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: Image.asset('assets/images/info.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Collapsible content
        AnimatedCrossFade(
          firstChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: Dimens.paddingXLarge),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.lightBlue, AppColors.tropicalBlue], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7],),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                if (widget.micronutrients.isNotEmpty) NutrientsSection(nutrients: widget.micronutrients.take((widget.objectives?.length ?? 0) * 3).toList(), title: AppLocalizations.of(context)!.objectives, image: 'assets/images/goal_objectives.png'),
                if (widget.temporaryMicronutrients.isNotEmpty) NutrientsSection(nutrients: widget.temporaryMicronutrients, titleColor: AppColors.redOxide, title: AppLocalizations.of(context)!.temporary_objectives, image: 'assets/images/hour_glass.png'),
                if (widget.filteredNutrientsLess15RDA.isNotEmpty) NutrientsSection(nutrients: widget.filteredNutrientsLess15RDA.where((element) => element.nutrientInfoMaster.translateDescription(context).isNotEmptyOrNull()).take(Constants.DASHBOARD_LIST_SIZE).toList(), titleColor: AppColors.tigerOrange, title: AppLocalizations.of(context)!.micros_keep_eye_on, image: 'assets/icon/deficiency_nutrients_icon.png'),
              ],),
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}
