import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrients_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/vertical_nutrient_widget.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'dash_title_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroNutrientsSection extends StatelessWidget {
  final List<NutrientsModel> micronutrients;
  final List<NutrientsModel> temporaryMicronutrients;
  final List<int>? objectives;
  const MicroNutrientsSection({super.key, required this.micronutrients, required this.temporaryMicronutrients, this.objectives});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
            child: DashTitleWidget(title: AppLocalizations.of(context)!.micronutrientss, onInfoClick: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: micronutrients))),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(vertical: Dimens.paddingXLarge),
          decoration: const BoxDecoration(
            // color: AppColors.lightBlue,
              gradient: LinearGradient(colors: [AppColors.lightBlue, AppColors.tropicalBlue], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7],),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              if (micronutrients.isNotEmpty) NutrientsSection(nutrients: micronutrients.take((objectives?.length ?? 0) * 3).toList(), title: AppLocalizations.of(context)!.objectives, image: 'assets/images/goal_objectives.png'),
              const SizedBox(width: Dimens.width18),
              if (temporaryMicronutrients.isNotEmpty) NutrientsSection(nutrients: temporaryMicronutrients, titleColor: AppColors.redOxide, title: AppLocalizations.of(context)!.temporary_objectives, image: 'assets/images/hour_glass.png'),
            ],),
          ),
        ),
      ],
    );
  }

}