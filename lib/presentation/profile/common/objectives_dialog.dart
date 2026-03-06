import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';

import '../../widgets/text_radio_button.dart';
import '../../widgets/text_radio_button_expansible.dart';

class ObjectivesDialog extends StatefulWidget {

  const ObjectivesDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ObjectivesDialogState();
}

class _ObjectivesDialogState extends State<ObjectivesDialog> {

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
        },
        builder: (ctx, state) {
          return SimpleDialog(
            backgroundColor: Colors.transparent,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white85Percent,
                        borderRadius: BorderRadius.circular(Dimens.border18),),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          AppLocalizations.of(ctx)!.objectives,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen),
                        ),
                            const SizedBox(height: Dimens.height27),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.metabolic_objectives, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),),
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
                        const SizedBox(height: Dimens.height27),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.body_composition_objectives, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),),
                            ...state.objectivesInfoMaster!.bodyCompositionObjectives.map((objective) =>
                                TextRadioButtonExpansible(
                                  title: objective.translate(context),
                                  explanation: '',
                                  isSelected: state.profile!.objectives.orEmpty().contains(objective.id),
                                  onPressed: () => bloc.add(AddRadioObjectiveToListAction(id: objective.id)),
                                ),
                            ).toList(),
                          ],
                        ),
                        const SizedBox(height: Dimens.height27),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.other_objectives, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),),
                            ...state.objectivesFilteredList.orEmpty().map((objective) =>
                                TextCheckboxBox(
                                  title: objective.translate(context),
                                  checkboxValue: state.profile!.objectives.orEmpty().contains(objective.id),
                                  onChangedCheckbox: () => bloc.add(AddObjectiveToListAction(id: objective.id)),
                                  overflow: TextOverflow.clip,
                                ),
                            ).toList(),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: Dimens.height32),
                    GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context),),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}