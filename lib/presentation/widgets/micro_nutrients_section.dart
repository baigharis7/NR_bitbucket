import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/vertical_nutrient_widget.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'dash_title_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroNutrientsSection extends StatelessWidget {
  final List<NutrientsModel> micronutrients;
  const MicroNutrientsSection({super.key, required this.micronutrients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
            child: DashTitleWidget(title: AppLocalizations.of(context)!.micronutrientss, onInfoClick: () => Navigator.pushNamed(context, MicroNutrientsDetailScreen.routeName, arguments: micronutrients))),
        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(vertical: Dimens.paddingXLarge),
          decoration: const BoxDecoration(
            // color: AppColors.lightBlue,
              gradient: LinearGradient(colors: [AppColors.lightBlue, AppColors.tropicalBlue], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7],)
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ...micronutrients.map((nutrient) => VerticalNutrientWidget(nutrient: nutrient)),
            ],),
          ),
        ),
      ],
    );
  }

}