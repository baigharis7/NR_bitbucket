import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';

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
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingNormal,
                vertical: Dimens.paddingNormal,
              ),
              child: Column(
                children: [
                  ...?state.fecesList?.map(
                    (fece) => RadioTitleDescImage(
                      isSelected: state.fecesSelected == fece.id,
                      fece: fece,
                      onSelect: (id) => fecesUrineBloc.add(UpdateFecesEventAction(feceId: id)),
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
