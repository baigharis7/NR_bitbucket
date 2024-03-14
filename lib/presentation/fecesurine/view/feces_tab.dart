import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../common/view/loading_screen.dart';

class FecesTab extends StatefulWidget {
  const FecesTab({super.key});

  @override
  State<FecesTab> createState() => _FecesTabState();
}

class _FecesTabState extends State<FecesTab> {
  late FecesUrineBloc fecesUrineBloc;

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    // fecesUrineBloc.add(InitializationEventAction());
    super.initState();
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingNormal,
                vertical: Dimens.paddingNormal,
              ),
              child: Column(
                children: [
                  ...state.fecesEvents.orEmpty().map(
                    (fece) => RadioTitleDescImage(
                      isSelected: true,
                      fece: state.fecesList.orEmpty().firstWhere((element) => element.id == fece.fecesId),
                      onSelect: (id) => fecesUrineBloc.add(DeleteFecesEventAction(uploadFeces: fece, onFinish: () => Navigator.pop(context))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
