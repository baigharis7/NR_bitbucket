import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/bloc/weekly_all_nutrients_bloc.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/micro_nutrient_detail_widget.dart';

class WeeklyAllNutrientsDetailScreen extends StatefulWidget {
  static const routeName = 'weekly_all_nutrients_detail_screen';

  const WeeklyAllNutrientsDetailScreen({super.key});

  @override
  State<WeeklyAllNutrientsDetailScreen> createState() =>
      _WeeklyAllNutrientsDetailScreenState();
}

class _WeeklyAllNutrientsDetailScreenState
    extends State<WeeklyAllNutrientsDetailScreen> {
  late WeeklyAllNutrientsBloc weeklyAllNutrientsBloc;

  @override
  void initState() {
    weeklyAllNutrientsBloc = BlocProvider.of<WeeklyAllNutrientsBloc>(context);
    weeklyAllNutrientsBloc.add(InitializationEventAction());
    final widgetBinding = WidgetsFlutterBinding.ensureInitialized();
    // widgetBinding.addPostFrameCallback((timeStamp) {
    //   final infoReceived = ModalRoute.of(context)!.settings.arguments;
    //   if (infoReceived != null) {
    //     if (infoReceived is List<NutrientsModel>) {
    //       weeklyAllNutrientsBloc.add(
    //           UpdateWeeklyListOfNutrients(weeklyMicronutrients: infoReceived));
    //     }
    //   }
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: weeklyAllNutrientsBloc,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                // size: 18,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.popAndPushNamed(context, ProfileScreen.routeName)
                        .then((value) {}),
                iconSize: 35.0,
                icon: Image.asset(
                  'assets/icon/profile_icon.png',
                  color: Colors.black,
                  height: 29,
                  width: 29,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(Dimens.heightSmall),
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginLarge),
                child: Text(
                  '${AppLocalizations.of(context)!.weekly_nutrients} ',
                  style: const TextStyle(fontSize: Dimens.fontSizeLarge,),
                ),
              ),
            ),
          ),
          body: BlocConsumer<WeeklyAllNutrientsBloc, WeeklyAllNutrientsState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }

              if (state.onError != null) showErrorSnackBar(ctx, resolveError(ctx, state.onError!));
            },
            builder: (context, state) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
              child: Column(
                children: [
                  ...state.weeklyMicronutrients
                      .orEmpty().where((element) => element.upperLimit > 0)
                      .map((item) => MicroNutrientDetailWidget(nutrientsModel: item,)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
