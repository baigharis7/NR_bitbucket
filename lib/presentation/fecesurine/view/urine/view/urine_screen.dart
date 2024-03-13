import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../domain/models/profile/feces.dart';
import '../../../../../infrastructure/utils/dimens.dart';
import '../../../../widgets/radio_title_desc_image.dart';
import '../../../../widgets/rounded_custom_button.dart';
import '../../../bloc/feces_urine_bloc.dart';

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
    fecesUrineBloc.add(InitializationEventAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: fecesUrineBloc,
      child: SafeArea(
        child: BlocConsumer<FecesUrineBloc, FecesUrineState>(
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(
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
                  ...?state.urinesList?.map(
                    (urine) => RadioTitleDescImage(
                      isSelected: -1 == urine.id,
                      fece: Feces(urine.id, urine.title, '', urine.image),
                      onSelect: (id) => fecesUrineBloc
                          .add(UpdateUrineEventAction(urineId: id)),
                    ),
                  ),
                ],
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
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
