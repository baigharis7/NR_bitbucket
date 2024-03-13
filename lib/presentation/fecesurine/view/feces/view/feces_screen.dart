import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../../../infrastructure/errors/error_resolver.dart';
import '../../../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../../../infrastructure/utils/dimens.dart';
import '../../../../common/view/loading_screen.dart';
import '../../../../widgets/radio_title_desc_image.dart';
import '../../../bloc/feces_urine_bloc.dart';

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
    fecesUrineBloc.add(InitializationEventAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: fecesUrineBloc,
      child: SafeArea(
        child: Scaffold(
          body: BlocConsumer<FecesUrineBloc, FecesUrineState>(
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
            builder: (context, state) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingNormal,
                vertical: Dimens.paddingNormal,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: Dimens.marginNormal),
                    child: InkWell(
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios),
                          Text(AppLocalizations.of(context)!.back),
                        ],
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(
                top: Radius.circular(5.0),
              ),
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5.0)],
            ),
            child: RoundedCustomButton(
              onPressed: () => fecesUrineBloc.add(UploadFecesEventAction(onFinish: () => Navigator.pop(context))),
            ),
          ),
        ),
      ),
    );
  }
}
