import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/feces.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/dashboard_calendar_widget.dart';
import '../../widgets/delete_item_dialog.dart';
import '../../widgets/feces_urine_chart.dart';
import '../../widgets/remove_item_widget.dart';
import '../../widgets/rounded_background_container.dart';

class UrineTab extends StatefulWidget {
  const UrineTab({super.key});

  @override
  State<UrineTab> createState() => _UrineTabState();
}

class _UrineTabState extends State<UrineTab> {
  late FecesUrineBloc fecesUrineBloc;

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    super.initState();
  }

  // TODO: Remove Item from db
  void _showRemoveDialog({required String description, required VoidCallback onCancel, required VoidCallback onConfirm}) {
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => RemoveItemWidget(
        description: description,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    return BlocProvider.value(
      value: fecesUrineBloc,
      child: SafeArea(
        child: BlocConsumer<FecesUrineBloc, FecesUrineState>(
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
          builder: (context, state) => Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                FecesUrineChart(
                  valuesList: state.urineChart14DaysData.orEmpty(),
                  imagePaths: state.urinesList.orEmpty().map((e) => e.image).toList(),
                ),
                const SizedBox(height: Dimens.height5),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.paddingNormal,
                    ),
                    child: Column(
                      children: state.urineDayEvents.orEmpty().map((urine) {
                          final urin = state.urinesList.orEmpty().firstWhere((element) => element.id == urine.fecesId);
                          return RadioTitleDescImage(
                            isSelected: true,
                            fece: Feces(urin.id, urin.title, '', urin.image),
                          onSelect: (id) => _showRemoveDialog(
                            description: AppLocalizations.of(context)!.remove_item(urin.title.orEmpty()),
                            onCancel: () => Navigator.pop(context),
                            onConfirm: () => fecesUrineBloc.add(DeleteUrineEventAction(uploadFeces: urine, onFinish: () {})),
                          ),
                            leading: Image.asset('assets/images/delete_icon.png', color: AppColors.floralWhite, width: Dimens.width20,),
                        );
                        }
                        ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
