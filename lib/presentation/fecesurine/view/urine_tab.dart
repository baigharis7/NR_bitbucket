import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/feces.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/dashboard_calendar_widget.dart';
import '../../widgets/delete_item_dialog.dart';
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

  Future<void> deleteItemDialog({String? title, required Function onDelete, required Function onCancel}) async {
    await showDialog(
      context: context,
      builder: (context) => DeleteItemDialog(
        onDelete: () => onDelete.call(),
        onCancel: () => onCancel.call(),
      ),
    ).then((value) => onCancel.call());
  }

  @override
  Widget build(BuildContext context) {
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
            body: Column(
              children: [
                RoundedBackgroundContainer(
                  margin: const EdgeInsets.all(Dimens.marginLarge,),
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.calendar),
                      const Icon(Icons.calendar_today_outlined),
                    ],),
                  onTap: () {
                    showDialog(context: context, builder: (context) => SimpleDialog(alignment: Alignment.topCenter,
                      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.padding9Large -5),
                      contentPadding: EdgeInsets.zero,
                      children: [
                        DashboardCalendarWidget(callGetAllEvents: (day) => fecesUrineBloc.getEventsForDay(state.urineEvents.orEmpty(), day)),
                      ],
                    ),
                    );
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.paddingNormal,
                    ),
                    child: Column(
                      children: state.urineEvents.orEmpty().map((urine) {
                          final urin = state.urinesList.orEmpty().firstWhere((element) => element.id == urine.fecesId);
                          return RadioTitleDescImage(
                            isSelected: true,
                            fece: Feces(urin.id, urin.title, '', urin.image),
                          onSelect: (id) => deleteItemDialog(
                            onDelete: () => fecesUrineBloc.add(DeleteUrineEventAction(uploadFeces: urine, onFinish: () => Navigator.pop(context))),
                            onCancel: ()=> Navigator.pop(context),
                          ),
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
