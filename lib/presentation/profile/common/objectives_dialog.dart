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
            backgroundColor: Colors.grey[100],
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: Dimens.marginXLarge, ),
                        child: Text(
                          AppLocalizations.of(ctx)!.objectives,
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeXXLarge,
                          ),
                        ),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                      RoundedCustomButton(onPressed: () => Navigator.pop(context),)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}