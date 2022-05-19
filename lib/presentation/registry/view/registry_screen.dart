import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/json_utils.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/diet_questions_modal.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/general_questions_modal.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/health_questions_modal.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/women_specific_questions_modal.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/selectable_option.dart';
import 'package:provider/provider.dart';

class RegistryScreen extends StatelessWidget with ShowLoadingDialog, GenericProvider<RegistryProvider> {
  RegistryScreen({Key? key}) : super(key: key);
  
  static const routeName = '/registry_screen';

  String _chooseRightLanguage(String languageCode, dynamic dynamic){
    String objectiveName = '';
    if (languageCode == 'es') {
      objectiveName = dynamic['es'];
    } else {
      objectiveName = dynamic['en'];
    }
    return objectiveName;
  }

  void _showObjectivesDialog(BuildContext context) async {
    final registryProvider = Provider.of<RegistryProvider>(context, listen: false);

    // TODO: cutrada que me permito para generar el JSON rápido. Cuando se guarde en Hive hacerlo bien.
    // TODO: esta lógica la tengo que sacar.
    final Map<String, dynamic> objectivesMap = await JsonUtils(context: context).readJson('assets/objectives_list.json');
    String code = Localizations.localeOf(context).languageCode;
    final List objectives = objectivesMap['objectives'].map((objective) => SimpleItem(
        name: _chooseRightLanguage(code, objective),
        id: int.parse(objective['id']),
    )).toList();

    showDialog(context: context, builder: (ctx) {
      return SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.instance.translate('objectives'),),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge),
            child: Text(
              AppLocalizations.instance.translate('objectives_question'),
              style: const TextStyle(
                fontSize: Dimens.fontSizeLarge
              ),),
          ),
          ...objectives.map((objective) => SelectableOption(
                isSelected: registryProvider.getObjectives.contains(objective.id),
                selectedItemsList: registryProvider.getObjectives,
                name: objective.name,
                id: objective.id,
                onTap: (id) => registryProvider.manageObjectives(id),
            )).toList()
        ],);
    });
  }

  void _showGeneralQuestions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return const GeneralQuestionsModal();
    });
  }

  void _showHealthQuestions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) {
      return const HealthQuestionsModal();
    });
  }

  void _showWomenHealthQuestions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) {
      return const WomenSpecificQuestionsModal();
    });
  }

  void _showDietQuestions(BuildContext context, Function onModalClosed) async {
    showModalBottomSheet(context: context, builder: (_) {
      return const DietQuestionsModal();
    }).whenComplete(() => onModalClosed.call());
  }

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<RegistryProvider>(context, listen: true));

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
                  child: Text(
                    AppLocalizations.instance.translate('profile_creation'),
                    style: const TextStyle(fontSize: Dimens.fontSizeXLarge),
                  ),
                ),
                InkWell(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                        child: Text(
                          AppLocalizations.instance.translate('objectives_question'),
                          style: getProvider.areObjectivesSelected()
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (getProvider.areObjectivesSelected()) const Icon(Icons.check, color: Colors.green,)
                    ],
                  ),
                  onTap: () =>_showObjectivesDialog(context),
                ),
                InkWell(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                        child: Text(
                          AppLocalizations.instance.translate('general_questions'),
                          style: getProvider.areGeneralQuestionsAnswered()
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (getProvider.areGeneralQuestionsAnswered()) const Icon(Icons.check, color: Colors.green,)
                    ],
                  ),
                  onTap: () => _showGeneralQuestions(context),
                ),

                InkWell(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                        child: Text(
                          AppLocalizations.instance.translate('health_questions'),
                          style: getProvider.areHealthQuestionsAnswered()
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (getProvider.areHealthQuestionsAnswered()) const Icon(Icons.check, color: Colors.green,)
                    ],
                  ),
                  onTap: () => _showHealthQuestions(context),
                ),
                getProvider.getSex == SexType.female
                    ? InkWell(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                        child: Text(
                          AppLocalizations.instance.translate('women_questions'),
                          style: getProvider.areWomenQuestionsAnswered()
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (getProvider.areWomenQuestionsAnswered()) const Icon(Icons.check, color: Colors.green,)
                    ],
                  ),
                  onTap: () => _showWomenHealthQuestions(context),
                )
                    : Container(),
                InkWell(
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                        child: Text(AppLocalizations.instance.translate('diet_questions'),
                          style: getProvider.areDietQuestionsAnswered()
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (getProvider.areDietQuestionsAnswered()) const Icon(Icons.check, color: Colors.green,)
                    ],
                  ),
                  onTap: () => _showDietQuestions(context, () => getProvider.setDietQuestionsChecked()),
                ),
                if (getProvider.showFinishButton())
                  Container(
                    margin: const EdgeInsets.only(top: Dimens.marginLarge),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        getProvider.finishRegistry(() {
                          Navigator.popAndPushNamed(context, DashboardScreen.routeName);
                        });
                      },
                      child: Text(AppLocalizations.instance.translate('accept')),
                    ),
                  )
              ],
            ),
          ),
          if (getProvider.isLoading) showLoadingDialog(context)
        ],
      ),
    );
  }
}
