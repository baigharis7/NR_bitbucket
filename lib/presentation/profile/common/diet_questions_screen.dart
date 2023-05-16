import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/diet_questions_header.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_image_checkbox.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_image_radio_button.dart';

class DietQuestionsScreen extends StatefulWidget {
  static const routeName = '/diet_question';
  const DietQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DietQuestionsScreenState();
}

class _DietQuestionsScreenState extends State<DietQuestionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

    void _showDietTypesDialog({
      required BuildContext context,
      required Function onClick,
      required Function stopShowingVegetarianDiets,
    }) {
      showDialog(
        context: context,
        builder: (ctx) {
          return BlocProvider.value(
            value: bloc,
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {},
              builder: (context, state) => SimpleDialog(
                backgroundColor: Colors.grey[100],
                children: [
                  DietQuestionsHeader(title: AppLocalizations.of(context)!.diet_type),
                  ...state.dietTypes!.map((dietType) {
                    return TextImageRadioButton(
                        title: dietType.name.orEmpty(),
                        image: Image.asset(
                          dietType.icon,
                          height: 27,
                          width: 27,
                        ),
                        isSelected: state.profile!.dietType == dietType.id,
                        onPressed: () {
                           if (dietType.id == Vegetarian().id) {
                            bloc.add(AddVegetarianDietsOptions(showVegetarianDiets: !bloc.state.showVegetarianDiets!));
                          } else {
                            onClick.call(dietType.id);
                          }
                        },
                    );
                  }),
                  RoundedCustomButton(
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          );
        },
      ).then((_) {
        stopShowingVegetarianDiets.call();
      });
    }

    void _showAllergensDialog(BuildContext context, Function onClick) {
      showDialog(
          context: context,
          builder: (ctx) {
            return BlocProvider.value(
              value: bloc,
              child: SimpleDialog(
                backgroundColor: Colors.grey[100],
                children: [
                  DietQuestionsHeader(title: AppLocalizations.of(context)!.allergens),
                  ...bloc.state.allergens!.map((allergen) {
                    return BlocConsumer<ProfileBloc, ProfileState>(
                      listener: (ctx, state) {},
                      builder: (ctx, state) {
                        return TextImageCheckbox(
                          title: allergen.name.orEmpty(),
                          isSelected: state.profile!.exclusions!.exclusions!.contains(allergen.id),
                          image: Image.asset(
                            allergen.icon.orEmpty(),
                            height: 30,
                            width: 30,
                          ),
                          onPressed: () => bloc.add(AddAllergenAction(allergenId: allergen.id!)),
                        );
                      },
                    );
                  }),
                  RoundedCustomButton(onPressed: () => Navigator.pop(context),)
                ],
              ),
            );},
      );
    }

    void _showIntolerancesDialog(BuildContext context, Function onClick) {
      showDialog(
          context: context,
          builder: (ctx) {
            return BlocProvider.value(
              value: bloc,
              child: SimpleDialog(
                backgroundColor: Colors.grey[100],
                children: [
                  DietQuestionsHeader(title: AppLocalizations.of(context)!.intolerances),
                  ...bloc.state.intolerances!.map((intolerance) {
                    return BlocConsumer<ProfileBloc, ProfileState>(
                      listener: (ctx, state) {},
                      builder: (stx, state) {
                        return TextCheckboxBox(
                          title: intolerance.name.orEmpty(),
                          checkboxValue: state.profile!.intolerances!.contains(intolerance.id),
                          onChangedCheckbox: () => bloc.add(AddIntolerancesAction(intoleranceId: intolerance.id!)),
                        );
                      },
                    );
                  }),
                  RoundedCustomButton(onPressed: () => Navigator.pop(context),)
                ],
              ),
            );
          },
      );
    }

    return SafeArea(
      child: BlocProvider.value(
        value: bloc,
        child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (ctx, state) {
                if (state.isLoading) {
                  LoadingScreen.instance().show(
                    context: ctx,
                    text: AppLocalizations.of(ctx)!.loading,
                  );
                } else {
                  LoadingScreen.instance().hide();
                }
              },
              builder: (BuildContext ctx, ProfileState state) {
                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal,),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24,),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: Dimens.marginNormal, bottom: Dimens.marginXXLarge),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    height: 59,
                                    width: 59,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: Dimens.marginXXLarge),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: Dimens.marginSmall,),
                                  child: Text(
                                    AppLocalizations.of(ctx)!.diet,
                                    style: const TextStyle(
                                      fontSize: Dimens.fontSizeXXLarge,
                                    ),
                                  ),
                                ),
                                Image.asset('assets/icon/omnivorous_icon.png')
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                            child: TextIconBox(
                              title: AppLocalizations.of(ctx)!.diet_type,
                              onAdd: () => _showDietTypesDialog(
                                context: ctx,
                                onClick: (id) => ctx.read<ProfileBloc>().add(SetDietTypeAction(dietType: id),),
                                stopShowingVegetarianDiets: () => bloc.add(StopShowingVegetarianDiets()),
                              ),
                              showAddButton: true,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                            child: TextIconBox(
                              title: AppLocalizations.of(ctx)!.allergens,
                              onAdd: () => _showAllergensDialog(ctx, (id) => ctx.read<ProfileBloc>().add(AddAllergenAction(allergenId: id)),),
                              showAddButton: true,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                            child: TextIconBox(
                              title: AppLocalizations.of(ctx)!.intolerances,
                              onAdd: () {
                                _showIntolerancesDialog(
                                  ctx,
                                  (id) => ctx.read<ProfileBloc>().add(AddIntolerancesAction(intoleranceId: id)),
                                );
                              },
                              showAddButton: true,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                            child: TextIconBox(
                              title: AppLocalizations.of(ctx)!.aversions,
                              onAdd: () => Navigator.pushNamed(context, AversionsScreen.routeName),
                              showAddButton: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                );
              },
            ),
        ),
      ),
    );
  }
}
