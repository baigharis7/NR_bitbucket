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

// TODO: think a new name for title and take it from AppLocalizations.
class HealthQuestionsScreen extends StatefulWidget {
  static const routeName = '/health_questions';
  const HealthQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HealthQuestionsScreen();
}

class _HealthQuestionsScreen extends State<HealthQuestionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

    return SafeArea(
      child: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          backgroundColor: Colors.white,
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
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: Dimens.marginNormal, bottom: Dimens.marginXLarge),
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
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                      color: Colors.grey[100],
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                top: Dimens.marginXXLarge,
                                bottom: Dimens.marginXLarge,
                            ),
                            child: Text(
                              AppLocalizations.of(ctx)!.medical_history,
                              style: const TextStyle(fontSize: Dimens.fontSizeXXLarge),
                            ),
                          ),
                          ...state.commonDiseases.orEmpty().map((commonDisease) {
                            return TextCheckboxBox(
                              title: commonDisease.name.orEmpty(),
                              checkboxValue: state.profile!.medicalSituation!
                                  .commonDiseases!.contains(commonDisease.id),
                              onChangedCheckbox: () =>
                                  bloc.add(ManageCommonDiseaseAction(commonDiseaseId: commonDisease.id!)),
                              overflow: TextOverflow.clip,
                            );
                          }).toList(),
                          RoundedCustomButton(onPressed: () => Navigator.pop(context),)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}