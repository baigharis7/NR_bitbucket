import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../../../domain/models/profile/feces.dart';
import '../../../../../infrastructure/errors/error_resolver.dart';
import '../../../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../../../infrastructure/utils/dimens.dart';
import '../../../../common/view/confirmation_dialog.dart';
import '../../../../common/view/loading_screen.dart';
import '../../../../widgets/general_button.dart';
import '../../../../widgets/radio_title_desc_image.dart';
import '../../../../widgets/rounded_custom_button.dart';
import '../../../bloc/feces_urine_bloc.dart';
import '../../feces_urine_tab_holder.dart';

class UrineScreen extends StatefulWidget {
  static const routeName = '/urine_screen';

  const UrineScreen({super.key});

  @override
  State<UrineScreen> createState() => _UrineScreenState();
}

class _UrineScreenState extends State<UrineScreen> {
  late FecesUrineBloc fecesUrineBloc;

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    fecesUrineBloc.add(InitializationUrineEventAction());
    super.initState();
  }

  // TODO: si esto permanece se puede convertir en un widget en un momento.
  void _showConfirmationDialog({String? message, required BuildContext context, Function? onDismiss}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: message ?? AppLocalizations.of(context)!.urine_event_successfully_saved),
    ),).then((value) {
      onDismiss?.call();
    }
    );
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
                  ...state.urinesList.orEmpty().map(
                        (urine) => RadioTitleDescImage(
                      isSelected: state.urineId == urine.id,
                      fece: Feces(urine.id, urine.title, '', urine.image),
                      onSelect: (id) => fecesUrineBloc
                          .add(UpdateUrineEventAction(urineId: id)),
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
              onTap: () => fecesUrineBloc.add(UploadUrineEventAction(onFinish: () => _showConfirmationDialog(
                message: AppLocalizations.of(context)!.urine_event_successfully_saved,
                context: context,
                onDismiss: () => Navigator.popAndPushNamed(context, FecesUrineTabHolder.routeName, arguments: 1),
              ),),),
            ),
          ),
        ),
      ),
    );
  }
}
