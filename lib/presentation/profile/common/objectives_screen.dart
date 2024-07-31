import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';
import '../../widgets/text_radio_button.dart';
import '../../widgets/text_radio_button_expansible.dart';
import 'general_questions_screen.dart';

class ObjectivesScreen extends StatefulWidget {
  static const routeName = '/objectives_screen';

  const ObjectivesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  showObjectivesErrorDialog(BuildContext context) {
    // final mediaQuerySize = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (ctx) => Container(
              padding: const EdgeInsets.all(Dimens.paddingLarge),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.red,),
              margin: const EdgeInsets.symmetric(
                  vertical: Dimens.margin6XLarge, horizontal: 75.0,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container()
                      // const Icon(
                      //   Icons.cancel,
                      //   color: Colors.white,
                      //   size: 24.0,
                      // )
                      ,),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.select_objective,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.fontSizeMedium,
                                decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ],
              ),
            ),);
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(InitializeStateFromRegistryAction(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

    return SafeArea(
        child: BlocProvider.value(
      value: bloc,
      child: Scaffold(
        // appBar: AppBar(
        //     backgroundColor: Colors.white,
        //     foregroundColor: Colors.black,
        //     leading: IconButton(
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //       icon: const Icon(Icons.arrow_back_ios, size: 24),
        //     )),
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
          builder: (ctx, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: Dimens.marginLarge,
                          vertical: Dimens.marginLarge,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              height: 59,
                              width: 59,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                              bottom: Dimens.marginXLarge,
                            ),
                            child: Text(
                              AppLocalizations.of(ctx)!.objectives,
                              style: const TextStyle(
                                fontSize: Dimens.fontSizeXXLarge,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginSmall),
                                  child: Text(AppLocalizations.of(context)!.metabolic_objectives, style: const TextStyle(
                                    fontSize: Dimens.fontSizeNormal,
                                    fontWeight: FontWeight.bold,
                                  ),)),
                              ...state.objectivesInfoMaster!.metabolicObjectives.map((objective) =>
                                  TextCheckboxBox(
                                    title: objective.translate(context),
                                    checkboxValue: state.profile!.objectives.orEmpty().contains(objective.id),
                                    onChangedCheckbox: () => bloc.add(AddObjectiveToListAction(id: objective.id)),
                                    overflow: TextOverflow.clip,
                                  ),
                              ).toList(),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginSmall),
                                  child: Text(AppLocalizations.of(context)!.body_composition_objectives, style: const TextStyle(
                                    fontSize: Dimens.fontSizeNormal,
                                    fontWeight: FontWeight.bold,
                                  ),)),
                              ...state.objectivesInfoMaster!.bodyCompositionObjectives.map((objective) =>
                                  TextRadioButton(
                                    title: objective.translate(context),
                                    isSelected: state.profile!.objectives.orEmpty().contains(objective.id),
                                    onPressed: () => bloc.add(AddRadioObjectiveToListAction(id: objective.id)),
                                  ),
                              ).toList(),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginSmall),
                                  child: Text(AppLocalizations.of(context)!.other_objectives, style: const TextStyle(
                                    fontSize: Dimens.fontSizeNormal,
                                    fontWeight: FontWeight.bold,
                                  ),)),
                              ...state.objectivesInfoMaster!.objectives.map((objective) =>
                                  TextCheckboxBox(
                                    title: objective.translate(context),
                                    checkboxValue: state.profile!.objectives.orEmpty().contains(objective.id),
                                    onChangedCheckbox: () => bloc.add(AddObjectiveToListAction(id: objective.id)),
                                    overflow: TextOverflow.clip,
                                  ),
                              ).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20,),
                      child: RoundedCustomButton(
                        onPressed: () {
                          if (state.profile!.objectives!.isNotEmpty) {
                            // bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, GeneralQuestionsScreen.routeName)));
                            Navigator.popAndPushNamed(
                                context, GeneralQuestionsScreen.routeName,);
                          } else {
                            showObjectivesErrorDialog(context);
                          }
                        },
                      ),),
                ),
              ],
            );
          },
        ),
        // bottomNavigationBar: ,
      ),
    ),);
  }
}
