import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_background_container.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/dashboard_calendar_widget.dart';
import '../../widgets/delete_item_dialog.dart';

class FecesTab extends StatefulWidget {
  const FecesTab({super.key});

  @override
  State<FecesTab> createState() => _FecesTabState();
}

class _FecesTabState extends State<FecesTab> {
  late FecesUrineBloc fecesUrineBloc;
  DateTime? selectedDateTime;

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    selectedDateTime = fecesUrineBloc.state.fecesDate;
    fecesUrineBloc.add(InitializationFecesEventAction(dateTime: selectedDateTime));
    super.initState();
  }

  Future<void> deleteItemDialog({String? title, required Function onDelete, required Function onCancel}) async {
    await showDialog(
      context: context,
      builder: (context) => DeleteItemDialog(
        onDelete: () => onDelete.call(),
        onCancel: () => onCancel.call(),
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
            body: Column(
              children: [
                RoundedBackgroundContainer(
                  margin: const EdgeInsets.all(
                    Dimens.marginLarge,
                  ),
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.calendar),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        alignment: Alignment.topCenter,
                        insetPadding: const EdgeInsets.symmetric(
                            horizontal: Dimens.paddingLarge,
                            vertical: Dimens.padding9Large - 5),
                        contentPadding: EdgeInsets.zero,
                        children: [
                          DashboardCalendarWidget(
                              callGetAllEvents: (day) =>
                                  fecesUrineBloc.getEventsForDay(
                                      state.fecesEvents.orEmpty(), day), focused: selectedDateTime, selectedDateForEventsLoading: (date) {
                                selectedDateTime = date;
                                fecesUrineBloc.add(InitializationFecesEventAction(dateTime: date, onFinish: () => Navigator.pop(context)));
                          }, currentLanguage: currentLanguage,),
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
                      children: state.facesDayEvents
                          .orEmpty()
                          .map(
                            (fece) => RadioTitleDescImage(
                              isSelected: true,
                              fece: state.fecesList.orEmpty().firstWhere(
                                  (element) => element.id == fece.fecesId),
                              onSelect: (id) =>
                                deleteItemDialog(
                                    onDelete: () => fecesUrineBloc.add(DeleteFecesEventAction(uploadFeces: fece, onFinish: () => Navigator.pop(context))),
                                    onCancel: ()=> Navigator.pop(context),
                                ),
                            ),
                          )
                          .toList(),
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
