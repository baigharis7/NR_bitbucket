import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../../../infrastructure/errors/error_resolver.dart';
import '../../../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../../../infrastructure/utils/dimens.dart';
import '../../../../common/view/loading_screen.dart';
import '../../../../widgets/radio_title_desc_image.dart';
import '../../../bloc/feces_urine_bloc.dart';
import '../../feces_urine_tab_holder.dart';

class FecesScreen extends StatefulWidget {
  static const routeName = '/feces_screen';

  const FecesScreen({super.key});

  @override
  State<FecesScreen> createState() => _FecesScreenState();
}

class _FecesScreenState extends State<FecesScreen> {
  late FecesUrineBloc fecesUrineBloc;

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    fecesUrineBloc.add(InitializationFecesEventAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: fecesUrineBloc,
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
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.paddingNormal,
                ),
                child: Column(
                  children: [
                    ...?state.fecesList?.map(
                          (fece) => RadioTitleDescImage(
                        isSelected: state.fecesId == fece.id,
                        fece: fece,
                        onSelect: (id) => fecesUrineBloc
                            .add(UpdateFecesEventAction(feceId: id)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.all(Dimens.marginNormal),
              child: GeneralButton(
                title: AppLocalizations.of(context)!.save,
                onTap: () => fecesUrineBloc.add(UploadFecesEventAction(onFinish: () => Navigator.popAndPushNamed(context, FecesUrineTabHolder.routeName, arguments: state.calendarDateTime))),
              ),
            ),
          ),
        ),
    );
  }
}
