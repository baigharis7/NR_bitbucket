import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/model/aversions_ui_model.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';

class FoodListAversionsScreen extends StatefulWidget {

  static const routeName = '/food_list_aversions';

  const FoodListAversionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodListAversionsScreenState();

}

class _FoodListAversionsScreenState extends State<FoodListAversionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    final foodGroup = ModalRoute.of(context)!.settings.arguments as FoodGroup;

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: ctx,
                text: AppLocalizations.of(ctx)!.loading,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (context, state) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
                      child: Image.asset(
                        'assets/images/logo_black.png',
                        width: 56,
                        height: 56,
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: Text(AppLocalizations.of(context)!.diet),
                          ),
                          Image.asset(
                            'assets/icon/food_icon.png',
                            height: 32,
                            width: 32,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${AppLocalizations.of(context)!.aversions}/${foodGroup.name}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                    ...foodGroup.foodsList.map((food) => TextCheckboxBox(
                      title: food.name,
                      checkboxValue: state.profile!.foodAversions!.contains(food.id),
                      onChangedCheckbox: () => bloc.add(ManageAversionsAction(foodId: food.id)),
                    ),)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}