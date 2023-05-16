import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/registry_card.dart';

class TestWidgetScreen extends StatelessWidget {
  const TestWidgetScreen({Key? key}) : super(key: key);
  static const routeName = '/test_screen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TestBloc(),
      child: Scaffold(
        body: BlocConsumer<TestBloc, TestState>(
          listener: (context, state) {

          },
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              child: RegistryCard(title: 'Dall-E', onClick: () {

              },),
            );
          },
        ),
      ),
    );
  }

}