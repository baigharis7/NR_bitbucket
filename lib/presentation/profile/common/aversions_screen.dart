import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/food_list_aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class AversionsScreen extends StatefulWidget {
  static const routeName = '/aversions';

  const AversionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AversionsScreenState();

}

class _AversionsScreenState extends State<AversionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

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
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new),
                          ),
                          Text(AppLocalizations.of(context)!.aversions)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: Dimens.marginNormal,
                          mainAxisExtent: 55.0,
                          childAspectRatio: 3/1,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...state.aversionsUI!.foodGroups.map((foodGroup) => Card(
                            elevation: 3.00,
                            shadowColor: Colors.black,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                onTap: () => Navigator.pushNamed(context, FoodListAversionsScreen.routeName, arguments: foodGroup),
                                child: Center(
                                  child: Text(
                                    foodGroup.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: Dimens.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                    if (state.profile!.foodAversions!.isNotEmpty) Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
                      child: Text(AppLocalizations.of(context)!.foods_selection),
                    ),
                    ...state.profile!.foodAversions!.map((foodId) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: Card(
                        elevation: 5.00,
                        color: Colors.teal[200],
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  bloc.findFoodNameFromFoodId(foodId).translate(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () => bloc.add(RemoveAversionAction(foodId: foodId)),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.teal,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
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


