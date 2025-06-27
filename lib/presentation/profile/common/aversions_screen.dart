import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/food_list_aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

import '../../../infrastructure/utils/constants.dart';

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
          return Stack(
            children: [
              // Background image or gradient
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'), // Your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Blur effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0), // Needed to activate the blur
                ),
              ),


              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimens.padding20),
                  child: Column(
                    children: [
                      Container(alignment: AlignmentDirectional.centerStart, child: IconButton(onPressed: () => Navigator.pop(context,), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,))),
                      Image.asset(
                        'assets/images/logo_name_white.png',
                        width: Dimens.width242,
                      ),
                      const SizedBox(height: Dimens.height32),
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
                              color: AppColors.floralWhite,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                                decoration: const BoxDecoration(
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
                                        fontWeight: FontWeight.w400,
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
                        child: Text(AppLocalizations.of(context)!.foods_selection, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeSmall, color: Colors.white)),
                      ),
                      ...state.profile!.foodAversions!.map((foodId) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                        child: Card(
                          elevation: 5.00,
                          color: AppColors.floralWhite,
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
                                      color: Colors.black,
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
                ),),
              ),
          ],);
        },
      ),
    );
  }

}


