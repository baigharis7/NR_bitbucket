import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/feces.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_title_desc_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: fecesUrineBloc,
      child: SafeArea(
        child: BlocConsumer<FecesUrineBloc, FecesUrineState>(
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ...?state.urinesList?.map((urine) => RadioTitleDescImage(
                  //     isSelected: -1 == urine.id,
                  //     fece: Feces(urine.id, urine.title, '', urine.image), onSelect: (id) => fecesUrineBloc.add(UpdateUrineEventAction(urineId: id)),
                  // ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
